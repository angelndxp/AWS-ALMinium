## AWS-ALMinium Ver2.5

## ＜これは何？＞
　GitHubで公開されているRedmineを一発展開できるOSS「<a href="https://github.com/alminium/alminium">ALMinium</a>」を、Amazon Web Serviceプラットフォームに展開しやすくするようにしたものです。Amazon Linuxインスタンス専用です。

* EC2インスタンスだけで使うEC2 Stand Alone版と、Amazon S3、Amazon RDS、Amzon SESを利用して高可用構成にするHigh Availability版があります。
* EC2にログインしてシェルをコピーして実行する方法、EC2起動の時に「UserData」に記述してEC2インスタンスにログインせずとも自動構築できる方法があります。(共通で使えるものにしました)
* EC2 Stand Alone版はオートスケールができないので、ELBを使わない想定でHTTP版とHTTPS版を準備しています。HTTPS版の証明書は、ALMinium自動インストールの際に設定される「自己証明書」になります。ALMiniumをとりあえず試してみたい方はこちらでどうぞ。
* ALMinium本体のインストールログが残るようにしました。(/usr/local/src/alminium/ALMinium_Install.log)
* EC2 Stand Alone版は、ALMiniumをコマンドで導入する時とやっていることは変わらず、メールも設定しません。(「User Data」で利用するときしか価値がないかも)
* High Availability版は、リポジトリ保存ディレクトリとFilesディレクトリがS3に、データベースがRDSに、システムメール配信がSESに設定されます。使うには各リソースの事前準備が必要です。

# ＜用意されているスクリプト＞
1. EC2 StandAlone ディレクトリ

* ALMinium_EC2StandAlone_http.sh (EC2 Stand Alone版 HTTPで構築) <a href="https://github.com/angelndxp/AWS-ALMinium/wiki/ALMinium_EC2StandAlone_http">ソース解説Wiki</a>
* ALMinium_EC2StandAlone_https.sh (EC2 Stand Alone版 HTTPSで構築) <a href="https://github.com/angelndxp/AWS-ALMinium/wiki/ALMinium_EC2StandAlone_https">ソース解説Wiki</a>

2. High Availability ディレクトリ

* ALMinium_EC2Install.sh (High Availability版 初回インストール用) <a href="https://github.com/angelndxp/AWS-ALMinium/wiki/ALMinium_EC2Install">ソース解説Wiki</a>
* ALMinium_EC2Install_Update.sh (High Availability版 アップデート用) <a href="https://github.com/angelndxp/AWS-ALMinium/wiki/ALMinium_EC2Install_Update">ソース解説Wiki</a>


# High Availability版を使うための設定準備
## ＜事前準備＞
* Amazon EC2のAmazon Linuxインスタンスを立ち上げてください。(64ビット、スモール以上を推奨)
* Amazon S3のバケットをあらかじめ準備しておいてください。
* Amazon RDSを、MySQLでセットアップしておいてください。
* Amazon SESをセットアップし、メール認証を完了させておいてください。

## ＜使用するのに必要なパラメーターとスクリプトの変数＞
サービス名 |パラメーター |スクリプト変数名 |備考
-----|-----|-----|-----
Amazon EC2|ALMiniumのホスト名(URL)|ALM_HOSTNAME|
Amazon S3|バケット名|BucketName|
Amazon S3|アクセスキー|AccessKey|
Amazon S3|シークレットアクセスキー|SecretAccessKey|
Amazon RDS|エンドポイント|RDSENDNAME|
Amazon RDS|データベース名|RDSDBNAME|
Amazon RDS|ユーザー名|RDSUser|
Amazon RDS|パスワード|RDSPass|
メール|メール設定を行うかどうかを設定|SMTPSET|メール設定をする[0]/しない[N]
メール|SMTPサーバー名|SMTPSERVER|
メール|暗号化が必要かどうかを設定|SMTPTLS|暗号化が必要[Y]/不要[n]
メール|メール送信ポート番号|SMTPPORT|
メール|認証(ログイン)が必要かどうかを設定|SMTPLOGIN|認証が必要[Y]/不要[n]
メール|SMTPユーザー名|SMTPUser|認証が不要な場合は空欄でもよい
メール|SMTPパスワード|SMTPPass|認証が不要な場合は空欄でもよい

## ＜メール関連のパラメーター設定について＞
* 有名なメールプロバイダを使う際の設定です。
* []のある設定値は固定値です。複数あるものは適切なものを選択してください。

### ・Amazon SESを利用する場合
変数名 |設定値
-----|-----
SMTPSET|[0]
SMTPSERVER|SMTP Server Name
SMTPTLS|[Y]
SMTPPORT|[25 or 465 or 587]
SMTPLOGIN|[Y]
SMTPUser|SMTP user name (IAM SMTP Credentialsの作成をして取得)
SMTPPass|SMTP password (IAM SMTP Credentialsの作成をして取得)

### ・G-Mail/Google Appsを利用する場合
変数名 |設定値
-----|-----
SMTPSET|[0]
SMTPSERVER|[smtp.gmail.com]
SMTPTLS|[Y]
SMTPPORT|[465]
SMTPLOGIN|[Y]
SMTPUser|G-Mailのユーザー名
SMTPPass|G-Mailのパスワード

### ・Windows Live Hotmailを利用する場合
変数名 |設定値
-----|-----
SMTPSET|[0]
SMTPSERVER|[smtp.live.com]
SMTPTLS|[n]
SMTPPORT|[587]
SMTPLOGIN|[Y]
SMTPUser|Microsoftアカウント ユーザー名
SMTPPass|Microsoftアカウント パスワード


## ＜使い方1. EC２インスタンスの中で使う＞
1. Amazon Linuxでインスタンスを起動します。(64ビット、スモール以上を推奨)
2. EC2インスタンスにログインしsudo suコマンドでroot権限ユーザーになります。
3. /usr/local/src に移動します。
4. 使いたいスクリプトをダウンロードして転送、もしくは新しいファイルに内容を全部コピーします。
5. viなどでファイルを開き、スクリプトの最初にある変数を埋めます。変数が何を意味しているかは、＜使用するのに必要なパラメーター＞にある変数名を参照してください。
6. shコマンドでスクリプトを走らせてください。

## ＜使い方2. EC２インスタンス作成時に「User Data」に埋め込んで使う＞
1. EC2インスタンスで、Amazon Linuxを選択してください。
2. インスタンスサイズは、64ビット、スモール以上にセットしてください。
3. 「Edit Ditails」を選択し、「Advanced Detailes」にある「User Data」のBOXの中に、スクリプトをコピーします。
4. スクリプトの最初にある変数を埋めます。変数が何を意味しているかは、＜使用するのに必要なパラメーター＞にある変数名を参照してください。
5. そのままインスタンスを立ちあげて、セットアップ完了までのんびりお待ちください。(1時間くらい)
6. インストールログを確認したい場合、EC２インスタンスにログインし、/var/log/cloud-init.logを確認すれば、初回起動時に行ったセットアップ内容が全て出力されています。

* 「User Data」のBOXが小さいので、テキストエディタ等で先に変数を埋めてからコピーするほうが楽かもしれません。

### ＜補足＞
* High Availability版はオートスケーリングができます。スクリプトでセットアップ後にEC2インスタンスをAMI化、ELBをセットアップし、オートスケーリングパラメーターをAMI化したインスタンスを利用するようにセットしてください。
* High Availability版はHTTP版しか準備していません。オートスケールをするにはELBによるオートバランサが必要であり、ELBに証明書をアップロードしてHTTPS化するほうが運用上理にかなっているからです。High Availability版をHTTPS化する場合はELBをセットアップしてください。
* EC2の「USER DATA」で使う場合「コメントアウトを認識しない」ため、意図的にコメントを付けない作り方にしています。コメント付きソースの解説は　GitHubのWikiに記述します。


## ＜セキュリティー上の注意＞
* パスワードを記述するスクリプトをEC2の「USER DATA」で使う場合、インスタンス上で特定のコマンドを打つと「USER DATA」の情報を引き出される可能性があります。インスタンスにログインする人の管理には十分気をつけてください。インストールを実行したインスタンスでない限り見えないので大丈夫だと思いますが、どうしても運用上気になるなら、インスタンスの中でスクリプトを実行してください。スクリプトは最後にサーバー再起動を命令するため自動消滅しません。構築後に書いたスクリプトを消しておくことが重要です。


## ＜High Availability版を使う利点＞
## 1. Amazon S3と、Amazon RDS の高可用なシステムを使う
* 「データの消えないストレージ」として設計され進化を続けるS3、ゾーンをまたいだMulti AZ配備ができるRDSと、EC2のEBSよりも高可用に設計されたシステムにデータ部分を移すことで、システムの信頼性が格段に向上します。
* S3には「容量の制限」という概念が存在せず、使った分だけ支払えば、S3の仕様の限界まで無限拡張可能です。
* RDSの容量拡張は、容量拡張設定をして「再起動を待つだけ」で簡単です。

## 2. 既存のものより、高可用設定が簡単で、使い勝手がいい
* BitNamiや、Right Scriptで作成したものは、「EC2の中で完結」します。これでは、真の高可用とはいえません。
* CloudFormationにRDSを用いたRedmineサンプルがあるが、これはリポジトリディレクトリやfilesディレクトリをEC2に残したままになります。
* CloudFormationのテンプレートや、BitNamiのAMIは、Redmineがほぼ「素」の状態なので、カスタムが必要です。
* EC2のEBSで容量限界に達すると、基本的に「全部作り直し」になるが、その心配から解放されます。

## 3. 設定により「スケーリング可能」な構成です
* データ部分を本体から追い出したことで、データベースの参照設定とS3のマウント設定を同じにすればスケール可能です。
* インストール後に、EBSイメージをAMI化し、ELB配下でオートスケールをさせても動作します。

## 4. S3をGradinetなどでマウントすれば、バックアップも簡単です
* リポジトリの中身や、Wikiの画像データなどは、すべてS3の中にありますので、取り出してバックアップすることが簡単にできます。(ただし、Outboundの転送料がかかります)

## 5.アップグレードも簡単です
1. 稼働しているものとは別のEC2インスタンスを準備します。
2. 同じパラメーターを使って 同じ手順で ALMinium_EC2Install_Update.sh を走らせます。このスクリプトは、初期設定の「DBの設定を移植する」部分を実行せず、ファイルマウントはALMiniumのインストール後の実行となるように変更してあります。
3. Redmineのバージョンによってうまく動かない場合、RDSでデータベースマイグレーションコマンドを走らせます。(方法はRedmineサイトを参照)
4. <注意>DBのマイグレーション処理により、「旧バージョンでは動きがおかしくなる」こともあるので、旧バージョンのEC2は止めて実施した方が無難です。
