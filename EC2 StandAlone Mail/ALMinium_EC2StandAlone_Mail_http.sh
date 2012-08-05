#!/bin/bash
ALMHOSTNAME=
SMTPSERVER=smtp.gmail.com
SMTPUser=
SMTPPass=
export HOME=/root
yum -y install git
cd /usr/local/src
git clone https://github.com/alminium/alminium.git
sed -i -e 's/read HOSTNAME/HOSTNAME='"$ALMHOSTNAME"'/' /usr/local/src/alminium/smelt
sed -i -e 's/read SSL/SSL=N/' /usr/local/src/alminium/smelt
sed -i -e 's/read USE_DISABLE_SECURITY/USE_DISABLE_SECURITY=Y/' /usr/local/src/alminium/inst-script/rhel6/pre-install
cd alminium
bash ./smelt > /usr/local/src/alminium/ALMinium_Install.log 2>&1
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
reboot