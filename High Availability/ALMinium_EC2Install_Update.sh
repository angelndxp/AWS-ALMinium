#!/bin/bash
ALMHOSTNAME=
BucketName=
AccessKey=
SecretAccessKey=
RDSENDNAME=
RDSDBNAME=
RDSUser=
RDSPass=
SMTPSERVER=
SMTPUser=
SMTPPass=
s3fs_var=1.61
export HOME=/root
yum -y install subversion make automake gcc libstdc++-devel gcc-c++ fuse fuse-devel curl-devel curl-devel libxml2-devel openssl-devel mailcap
yum -y install git
cd /usr/local/src
wget http://s3fs.googlecode.com/files/s3fs-$s3fs_var.tar.gz
tar xvzf s3fs-$s3fs_var.tar.gz
cd /usr/local/src/s3fs-$s3fs_var/
./configure --prefix=/usr
make
make install
rm -rf /usr/local/src/s3fs-$s3fs_var.tar.gz
echo $BucketName:$AccessKey:$SecretAccessKey > /etc/passwd-s3fs
chmod 640 /etc/passwd-s3fs
cd /usr/local/src
git clone https://github.com/alminium/alminium.git
sed -i -e 's/read HOSTNAME/HOSTNAME='"$ALMHOSTNAME"'/' /usr/local/src/alminium/smelt
sed -i -e 's/read SSL/SSL=N/' /usr/local/src/alminium/smelt
sed -i -e 's/read USE_DISABLE_SECURITY/USE_DISABLE_SECURITY=Y/' /usr/local/src/alminium/inst-script/rhel6/pre-install
cd /usr/local/src/alminium
bash ./smelt > /usr/local/src/alminium/ALMinium_Install.log 2>&1
mkdir -p /mnt/s3
s3fs $BucketName /mnt/s3 -o allow_other -o allow_other,default_acl=public-read
cd /mnt/s3
rm -rf /opt/alminium/
rm -rf /opt/alminium/files
ln -s /mnt/s3/alminium /var/opt/alminium
ln -s /mnt/s3/files /opt/alminium/files
echo "/usr/bin/s3fs#$BucketName /mnt/s3 fuse allow_other,default_acl=public-read 0 0" >> /etc/fstab
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
service mysqld stop
chkconfig mysqld off
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
sed -i -e 's/DBI:mysql:database=alminium;host=localhost/DBI:mysql:database='"$RDSDBNAME"';host='"$RDSENDNAME"'/' /etc/httpd/conf.d/vcs.conf
sed -i -e 's/RedmineDbUser "alminium"/RedmineDbUser "'"$RDSUser"'"/' /etc/httpd/conf.d/vcs.conf
sed -i -e 's/RedmineDbPass "alminium"/RedmineDbPass "'"$RDSPass"'"/' /etc/httpd/conf.d/vcs.conf
service httpd restart
reboot
