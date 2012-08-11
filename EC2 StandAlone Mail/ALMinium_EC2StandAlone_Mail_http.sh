#!/bin/bash
ALM_HOSTNAME=
SMTPSERVER=smtp.gmail.com
SMTPUser=
SMTPPass=
export HOME=/root
SSL=N
USE_DISABLE_SECURITY=Y
yum -y install git
cd /usr/local/src
git clone https://github.com/alminium/alminium.git
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
