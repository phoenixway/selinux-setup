#!/bin/bash

# Налаштування змінних
green_color="\e[32m"
green_bold_color="\033[32;1m"
source_dir="/home/roman/studio_it/app1"
dest_dir="/home/roman/studio_it/safe1"
policy="app1"
declare -a execs
# execs[0]="${source_dir}/app1.sh"
execs[0]="${source_dir}/hello-world"
execs[1]="/usr/bin/keepassxc"

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

tasks_group_start() {
  echo -e -n "\033[32;1m$*\033[0m"
}

function tasks_group_success() {
  echo -e "\r$1[✔] $2"
}

blue() {
   # Коди ANSI для встановлення кольору та стилю
  reset="\033[0m"
  
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
  red_bold="\e[31m"
  reset="\033[0m"
  green="\e[32m"
  blue="\e[34m"

  # Передані аргументи - це наші строки
  string1="$1"
  string2="$2"

  # Виводимо строки з потрібним форматуванням
  echo -e "${red_bold}${string1}${reset}${string2}"
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

remove_existed_policies() {
  green_bold Removing existing policies..
  # Save command output to variable
output=$(sudo semanage fcontext -l | grep app1)

# Check if output exists and process it
if [ ! -z "$output" ]; then
   # Create array for paths
   declare -a paths

   # Read each line of output
   while IFS= read -r line; do
       # Extract first field (path) from each line
       path=$(echo "$line" | awk '{print $1}')
       # Check if path is not empty
       if [ ! -z "$path" ]; then
           # Add path to array
           paths+=("$path")
       fi
   done <<< "$output"

   # Process array and remove contexts if array is not empty
   if [ ${#paths[@]} -gt 0 ]; then
       for path in "${paths[@]}"; do
           blue "Removing context for: $path"
           sudo semanage fcontext -d "$path"
       done
   else
       blue "No paths found for removal"
   fi
else
   blue "No contexts found for app1."
fi

if sudo semodule -lfull | grep -q "app1"; then
    blue "Module app1 loaded. Removing..."
    sudo semodule -r app1 > /dev/null 2>&1
else
    blue "Module app1 is not loaded."
fi
}

change_encoding() {
  tasks_group_start "Changing source encoding.."
  iconv -f UTF-8 -t ASCII//TRANSLIT app1.te > app1_ascii.te
  mv app1_ascii.te app1.te
  sed -i 's/\r$//' app1.te
  tasks_group_success $green_bold_color "Changed source encoding."
}

install_modules_with_make() {
  tasks_group_start Installing new policies..
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
  tasks_group_success $green_bold_color "Installed new policies."
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
  blue "Resetting execs.."
  for element in "${execs[@]}"
  do
    echo "Resetting $element.."
    run_command sudo chcon -t secure_app_exec_t $element
    sudo chmod +x $element
    run_command  sudo semanage fcontext -a -t secure_app_exec_t "$element"
    run_command sudo restorecon -Fv $elements
  done
  blue "Resetting $dest_dir.."
  run_command sudo chcon -R -t secure_app_data_t $dest_dir
  run_command sudo semanage fcontext -a -t secure_app_data_t \'$dest_dir'(/.*)?'\'
  run_command sudo restorecon -RFv $dest_dir
  # run_command sudo restorecon -R -v $dest_dir

  # run_command sudo semanage fcontext -a -t secure_app_exec_t \'/home/.*/selinux-policies/app1/app1\.sh\'
  # run_command sudo semanage fcontext -a -t secure_app_data_t \'/home/.*/selinux-policies/app1/safe1\(/.*\)?\'
  # run_command sudo restorecon -R -v \'/home/*/selinux-policies/app1/\'
}

do_testing() {
  green_bold Testing result..
  blue "Testing permissions"
  for element in "${execs[@]}"
  do
    echo "ls -Zd $element"
    ls -Zd $element
  done
  blue "Testing secure_app_data_t"
  echo "ls -Zd $dest_dir/*"
  ls -Zd $dest_dir/*
  echo "ls -Zd $dest_dir"
  ls -Zd $dest_dir
  echo "touch $dest_dir/test10.txt"
  touch $dest_dir/test10.txt
  echo "rm $dest_dir/test10.txt"
  rm $dest_dir/test10.txt
  green "Permissive"
  sudo setenforce 0
  ls -Zd $dest_dir
  sudo setenforce 1
  green "Enforcing"
  blue "./hello-world"
  ./hello-world
}

reset_selinux() {
    tasks_group_start Resetting selinux..
    sudo setenforce 0
    sudo setenforce 1
    tasks_group_success $green_bold_color "Resetted selinux."
}
if [[ "$flag_r" == true ]]; then
  remove_existed_policies
  exit 0
fi
green "==========================Let's start!================================"
remove_existed_policies
change_encoding
install_modules_with_make 
reset_contexts
reset_selinux
do_testing
green_bold "Done!"
