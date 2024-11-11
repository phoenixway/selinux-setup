#!/bin/bash
set -x
ls -Zd app1.sh
ls -Zd safe1/

./run.sh
./app1.sh
sudo setenforce 0
ls -Zd safe1/
./app1.sh
sudo setenforce 1
./app1.sh
sudo chcon -R -t secure_app_data_t /home/roman/selinux-policies/app1/safe1
# sudo ausearch -m AVC -ts recent
# sudo audit2allow -a -M secure_app_user_home
sudo ausearch -m AVC -ts recent | sudo audit2allow -a

