#!/bin/bash
set -x
ls -Z app1.sh
ls -Z safe1/

./run.sh
./app1.sh

# sudo ausearch -m AVC -ts recent
# sudo audit2allow -a -M secure_app_user_home
sudo ausearch -m AVC -ts recent | sudo audit2allow -a

