#!/bin/bash

# Налаштування змінних
source_dir="/home/roman/selinux-policies/app1"
dest_dir="$source_dir/safe1"
addressed_app="$source_dir/app1.sh"
policy="app1"

# Перевірка наявності флага -d
debug=false
while getopts "d" opt; do
  case $opt in
    d)
      debug=true
      ;;
    \?)
      echo "Невідомий параметр: -$OPT" >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

# Функція для виведення повідомлень з відлагодженням
debug_msg() {
  if [[ $debug == true ]]; then
    echo "$1"
  fi
}

# Видалення контекстів з файлів
debug_msg "Видаляю контексти з файлів в $dest_dir і $addressed_app"
sudo semanage fcontext -d "$addressed_app"
sudo restorecon -Rv "$addressed_app"
#sudo semanage fcontext -d "$dest_dir"
sudo semanage fcontext -d "$dest_dir(/.*)?"
sudo restorecon -Rv "$dest_dir"
sudo restorecon -Rv "$dest_dir/*"
	
# Видалення політики
debug_msg "Видаляю політику $policy"
sudo semodule -r $policy
if [ $? -ne 0 ]; then
  echo "Помилка при видаленні політики $policy"
fi

debug_msg "Готово!"

