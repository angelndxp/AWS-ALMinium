#!/bin/bash
ALM_HOSTNAME=
export HOME=/root
SSL=N
USE_DISABLE_SECURITY=Y
yum -y install git
cd /usr/local/src
git clone https://github.com/alminium/alminium.git
cd alminium
bash ./smelt > /usr/local/src/alminium/ALMinium_Install.log 2>&1
reboot
