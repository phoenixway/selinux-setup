#!/bin/bash
secure_folder="/home/roman/selinux-policies/app1/safe1"
# Встановлюємо контекст для папки
sudo semanage fcontext -a -t secure_app_data_t "$secure_folder(/.*)?"
sudo restorecon -R -v $secure_folder

