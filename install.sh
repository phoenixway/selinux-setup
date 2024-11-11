#!/bin/bash

# Налаштування змінних
source_dir="/home/roman/selinux-policies/app1"
dest_dir="$source_dir/safe1"
policy="app1"
addressed_app="$source_dir/app1.sh"
debug=false

# Перевірка наявності флага -i та -d
while getopts ":i:d" opt; do
  case $opt in
    i)
      policy="$OPTARG"
      ;;
    d)
      debug=true
      ;;
    \?)
      echo "Невідомий параметр: -$OPTARG" >&2
      exit 1
      ;;
  esac
done


# Функція для виведення повідомлень з відлагодженням
debug_msg() {
  if [[ $debug == true ]]; then
    echo "$1"
  fi
}

# Функція для виведення повідомлень про помилки та завершення скрипту
error_exit() {
  echo "Помилка: $1" >&2
  exit 1
}
./remove-policy.sh

iconv -f UTF-8 -t ASCII//TRANSLIT app1.te > app1_ascii.te
mv app1_ascii.te app1.te
sed -i 's/\r$//' app1.te


# Компіляція модуля
#checkmodule -M -m -o "$policy.mod" "$policy.te" || error_exit "Помилка при компіляції модуля"

# Пакетування модуля
#semodule_package -o "$policy.pp" -m "$policy.mod" || error_exit "Помилка при пакетуванні модуля"

# Інсталяція політики
#sudo semodule -i "$policy.pp" || error_exit "Помилка при інсталяції політики"

make -f /usr/share/selinux/devel/Makefile clean
make -f /usr/share/selinux/devel/Makefile || error_exit "Помилка make"
sudo semodule -i $policy.pp || error_exit "Помилка при встановленні модуля" 

sudo restorecon -RFv $dest_dir
sudo restorecon -Fv $addressed_app
./context2app.sh
./context2dir.sh
sudo semanage fcontext -a -t secure_app_exec_t "/home/.*/selinux-policies/app1/app1\.sh"
sudo semanage fcontext -a -t secure_app_data_t "/home/.*/selinux-policies/app1/safe1(/.*)?"
sudo restorecon -R -v /home/*/selinux-policies/app1/
sudo setenforce 0
sudo setenforce 1
./test.sh
echo "Done!"
