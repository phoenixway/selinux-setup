#!/bin/bash
app_path="/home/roman/selinux-policies/app1/app1.sh"

# Встановлюємо контекст для програми
sudo semanage fcontext -a -t secure_app_exec_t "$app_path"
sudo restorecon -v $app_path
