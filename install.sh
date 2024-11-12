#!/bin/bash

# Налаштування змінних
source_dir="/home/roman/selinux-policies/app1"
dest_dir="$source_dir/safe1"
policy="app1"
addressed_app="$source_dir/app1.sh"
debug=false
flag_r=false
while getopts "dr" opt; do
  case $opt in
    d)
      echo "Flag -d detected"
      debug=true
      ;;
    r)
      echo "Flag -r detected"
      flag_r=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND -1))

green_bold() {
  echo -e "\033[32;1m$*\033[0m"
}

blue() {
   # Коди ANSI для встановлення кольору та стилю
  reset="\033[0m"
  green="\e[32m"
  blue="\e[34m"

  # Передані аргументи - це наші строки
  string1="$*"

  # Виводимо строки з потрібним форматуванням
  echo -e "${blue}${string1}${reset}"
}

green() {
   # Коди ANSI для встановлення кольору та стилю
  reset="\033[0m"
  green="\e[32m"
  blue="\e[34m"

  # Передані аргументи - це наші строки
  string1="$*"

  # Виводимо строки з потрібним форматуванням
  echo -e "${green}${string1}${reset}"
}

function print_colored_bold() {
  # Коди ANSI для встановлення кольору та стилю
  red_bold="\e[1;31m"
  reset="\033[0m"
  green="\e[32m"
  blue="\e[34m"

  # Передані аргументи - це наші строки
  string1="$1"
  string2="$2"

  # Виводимо строки з потрібним форматуванням
  echo -e "${red_bold}${string1}${reset}"
  echo $string2
}

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

run_command() {
  local command="$@"
  #for command in "$@"; do
    if [[ $debug == true ]]; then
      debug_msg "Виконую: $command"
    fi
    output=$(eval "$command" 2>&1)
    exit_code=$?

    if [[ "$exit_code" -ne 0 || "$debug" == "true" ]]; then
        print_colored_bold "Команда: $command"
        print_colored_bold "Вихідний код: $exit_code"
        echo "Вивід команди:"
        echo "$output"
        return 2
    fi
}

# Функція для виконання команди з перевіркою на помилки
run_command333() {
  local command="$@"
  if [[ $debug == true ]]; then
    debug_msg "Виконую: $command"
  fi
  # Перенаправляємо стандартний вивід і помилки в /dev/null, якщо debug=false
  if [[ $debug == false ]]; then
    $command > /dev/null 2>&1
  else
    $command
  fi
  # Перевірка на помилку
  if [[ $? -ne 0 ]]; then
    error_exit "Помилка при виконанні команди: $command"
  fi
}

remove_existed_policies() {
  green_bold Removing existing policies..
  run_command ./remove-policy.sh
  if [ $? -eq 0 ]; then
    true
  else
    error_exit "Виникла помилка"
  fi
}

change_encoding() {
  green_bold Changing source encoding..
  iconv -f UTF-8 -t ASCII//TRANSLIT app1.te > app1_ascii.te
  mv app1_ascii.te app1.te
  sed -i 's/\r$//' app1.te
}

install_modules_with_make() {
  green_bold Installing new policies..
  run_command make -f /usr/share/selinux/devel/Makefile clean
  if [ $? -eq 0 ]; then
    true
  else
    error_exit "Виникла помилка"
  fi
  run_command make -f /usr/share/selinux/devel/Makefile || error_exit "Помилка make"
  if [ $? -eq 0 ]; then
    true
  else
    error_exit "Виникла помилка"
  fi
  run_command sudo semodule -i $policy.pp || error_exit "Помилка при встановленні модуля"
  if [ $? -eq 0 ]; then
    true
  else
    error_exit "Виникла помилка"
  fi
}

install_modules_with_seutils() {
  Компіляція модуля
  checkmodule -M -m -o "$policy.mod" "$policy.te" || error_exit "Помилка при компіляції модуля"

  Пакетування модуля
  semodule_package -o "$policy.pp" -m "$policy.mod" || error_exit "Помилка при пакетуванні модуля"

  Інсталяція політики
  sudo semodule -i "$policy.pp" || error_exit "Помилка при інсталяції політики"
}

reset_contexts() {
  green_bold Resetting files and folders contexts..

  run_command sudo restorecon -RFv $dest_dir
  run_command chcon -t secure_app_exec_t $addressed_app
  chmod +x $addressed_app
  run_command sudo restorecon -Fv $addressed_app
  
  # Встановлюємо контекст для програми
  run_command  sudo semanage fcontext -a -t secure_app_exec_t "$addressed_app"
  run_command sudo restorecon -v $addressed_app
  # Встановлюємо контекст для папки
  # run_command sudo chcon -R -t secure_app_data_t $dest_dir
  # run_command sudo semanage fcontext -a -t secure_app_data_t \'$dest_dir'(/.*)?'\'
  run_command sudo restorecon -R -v $dest_dir

  run_command sudo semanage fcontext -a -t secure_app_exec_t \'/home/.*/selinux-policies/app1/app1\.sh\'
  # run_command sudo semanage fcontext -a -t secure_app_data_t \'/home/.*/selinux-policies/app1/safe1\(/.*\)?\'
  run_command sudo restorecon -R -v \'/home/*/selinux-policies/app1/\'
}

do_testing() {
  green_bold Testing result..
  blue "Testing permissions"
  ls -Zd app1.sh
  ls -Zd /home/roman/selinux-policies/app1/safe1
  ls -Zd /home/roman/selinux-policies/app1/safe1/*
  blue "./run.sh"
  ./run.sh
  blue "./app1.sh"
  ./app1.sh
  green "Permissive"
  sudo setenforce 0
  ls -Zd safe1/
  blue "./app1.sh with permissive"
  ./app1.sh
  sudo setenforce 1
  blue "./app1.sh with enforcing"
  ./app1.sh
  #sudo chcon -R -t secure_app_data_t /home/roman/selinux-policies/app1/safe1
  #sudo ausearch -m AVC -ts recent > /dev/null 2>&1
  #sudo audit2allow -a -M secure_app_user_home > /dev/null 2>&1
  # sudo ausearch -m AVC -ts recent | sudo audit2allow -a > /dev/null 2>&1
  #./test.sh
}

reset_selinux() {
    green_bold Resetting selinux..
    sudo setenforce 0
    sudo setenforce 1
}
if [[ "$flag_r" == true ]]; then
  remove_existed_policies
  exit 0
fi
remove_existed_policies
change_encoding
install_modules_with_make 
reset_contexts
reset_selinux
do_testing
green_bold "Done!"
