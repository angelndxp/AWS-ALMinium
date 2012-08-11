#!/bin/bash
ALMHOSTNAME=
export HOME=/root
yum -y install git
cd /usr/local/src
git clone https://github.com/alminium/alminium.git
sed -i -e 's/read HOSTNAME/HOSTNAME='"$ALMHOSTNAME"'/' /usr/local/src/alminium/smelt
sed -i -e 's/read SSL/SSL=y/' /usr/local/src/alminium/smelt
sed -i -e 's/read USE_DISABLE_SECURITY/USE_DISABLE_SECURITY=Y/' /usr/local/src/alminium/inst-script/rhel6/pre-install
cd alminium
bash ./smelt > /usr/local/src/alminium/ALMinium_Install.log 2>&1
reboot
