#!/bin/sh

# Additional Paramater
## ALMinium サーバーの HOSTNAME
ALMHOSTNAME=

## Amazon S3 Bucket Name
BucketName=

## Amazon S3 Access Key
AccessKey=

## Amazon S3 Secret Access Key
SecretAccessKey=

## Amazon RDS Endpoint
RDSENDNAME=

## Amazon RDS Database Name
RDSDBNAME=

## Amazon RDS User
RDSUser=

## Amazon RDS Password
RDSPass=

## Amazon SES SMTP Server
SMTPSERVER=

## Amazon SES Username
SMTPUser=

## Amazon SES Password
SMTPPass=

## s3fs の tar.gzバージョン
s3fs_var=1.61


# 必要なRPMパッケージのインストール
## for s3fs
yum -y install subversion make automake gcc libstdc++-devel gcc-c++ fuse fuse-devel curl-devel curl-devel libxml2-devel openssl-devel mailcap
## for alminium
yum -y install git


# s3fsのインストール
# svnインストールはバグ持ち 20120718
cd /usr/local/src
wget http://s3fs.googlecode.com/files/s3fs-$s3fs_var.tar.gz
tar xvzf s3fs-$s3fs_var.tar.gz
cd /usr/local/src/s3fs-$s3fs_var/
./configure --prefix=/usr
make
make install
rm -rf /usr/local/src/s3fs-$s3fs_var.tar.gz

# Amazon S3キーファイル作成、パーミッション設定
#echo <bukketID>:<AccessKey>:<SeacretKey> > /etc/passwd-s3fs
echo $BucketName:$AccessKey:$SecretAccessKey > /etc/passwd-s3fs
chmod 640 /etc/passwd-s3fs

# Amazon S3マウント、シンボリックリンク作成
# s3fs <bukketID> /mnt/s3
mkdir -p /mnt/s3
s3fs $BucketName /mnt/s3 -o allow_other -o allow_other,default_acl=public-read
cd /mnt/s3
mkdir -p /mnt/s3/alminium
mkdir -p /mnt/s3/files
mkdir -p /opt/alminium/
ln -s /mnt/s3/alminium /var/opt/alminium
ln -s /mnt/s3/files /opt/alminium/files

# 自動マウント設定
# echo "/usr/bin/s3fs#<Bucket Name> /mnt/s3 fuse allow_other,default_acl=public-read 0 0" >> /etc/fstab
echo "/usr/bin/s3fs#$BucketName /mnt/s3 fuse allow_other,default_acl=public-read 0 0" >> /etc/fstab


#alminiumのインストール
## ダウンロード
cd /usr/local/src
git clone https://github.com/alminium/alminium.git

## インストールパラメーター設定
### HOSTNAME
sed -i -e 's/read HOSTNAME/HOSTNAME='"$ALMHOSTNAME"'/' /usr/local/src/alminium/smelt
### SSL Support
sed -i -e 's/read SSL/SSL=N/' /usr/local/src/alminium/smelt
### SELINUX解除
sed -i -e 's/read USE_DISABLE_SECURITY/USE_DISABLE_SECURITY=Y/' /usr/local/src/alminium/inst-script/rhel6/pre-install

## インストール実行
cd /usr/local/src/alminium
bash ./smelt

## DBをダンプ
cd /usr/local/src
mysqldump -u root alminium > /usr/local/src/dump.sql

## DBをRDSに入れる
# mysql -h <RDS Host Name> <DB Name> -u<userid>  -p<passwd> < /usr/local/src/dump.sql/dump.sql
mysql -h "$RDSENDNAME" "$RDSDBNAME" -u"$RDSUser"  -p"$RDSPass" < /usr/local/src/dump.sql
rm -rf /usr/local/src/dump.sql

## DB接続変更
echo -e "production-sqlite:
  adapter: sqlite3
  database: db/alminium.sqlite3

production:
  adapter: mysql2
  database: $RDSDBNAME
  host: $RDSENDNAME
  username: $RDSUser
  password: $RDSPass
  encoding: utf8" > /opt/alminium/config/database.yml

## ローカルDBサーバー停止
service mysqld stop
chkconfig mysqld off

## メール接続設定の作成
echo -e "default:
 email_delivery:
    delivery_method: :smtp
    smtp_settings:
      tls: true
      address: $SMTPSERVER
      port: 465
      domain: $ALMHOSTNAME
      authentication: :login
      user_name: $SMTPUser
      password: $SMTPPass" > /opt/alminium/config/configuration.yml

## 認証DB接続設定変更
sed -i -e 's/DBI:mysql:database=alminium;host=localhost/DBI:mysql:database='"$RDSDBNAME"';host='"$RDSENDNAME"'/' /etc/httpd/conf.d/vcs.conf
sed -i -e 's/RedmineDbUser "alminium"/RedmineDbUser "'"$RDSUser"'"/' /etc/httpd/conf.d/vcs.conf
sed -i -e 's/RedmineDbPass "alminium"/RedmineDbPass "'"$RDSPass"'"/' /etc/httpd/conf.d/vcs.conf

## SSL.confの記述
# sed -i -e 's/#ServerName www.example.com:443/ServerName '"$ALMHOSTNAME"':443/' /etc/httpd/conf.d/ssl.conf

## httpd再起動
service httpd restart

# インストール終了表示
echo "Install Complete"

# シェルスクリプトを消滅させる
rm -f $0
