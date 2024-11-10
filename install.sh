#!/bin/bash

# Налаштування змінних
source_dir="/home/roman/selinux-policies/app1"
dest_dir="$source_dir/safe1"
policy="app1"

# Перевірка наявності флага -i
while getopts ":i:" opt; do
  case $opt in
    i)
      policy="$OPTARG"
      ;;
    \?)
      echo "Невідомий параметр: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Функція для виведення повідомлень про помилки та завершення скрипту
error_exit() {
  echo "Помилка: $1" >&2
  exit 1
}

# Компіляція модуля
checkmodule -M -m -o "$policy.mod" "$policy.te" || error_exit "Помилка при компіляції модуля"

# Пакетування модуля
semodule_package -o "$policy.pp" -m "$policy.mod" || error_exit "Помилка при пакетуванні модуля"

# Інсталяція політики
sudo semodule -i "$policy.pp" || error_exit "Помилка при інсталяції політики"

echo "Done!"
