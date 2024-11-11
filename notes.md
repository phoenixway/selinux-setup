# Add these permissions to allow shell script execution
allow secure_app_t shell_exec_t:file { execute getattr read open execute_no_trans entrypoint };
allow secure_app_t bin_t:file { execute getattr read open execute_no_trans };

# Allow reading and executing libraries
allow secure_app_t lib_t:file { execute getattr read open map };

# Add transition rules for process execution
type_transition unconfined_t secure_app_exec_t:process secure_app_t;
allow unconfined_t secure_app_t:process transition;


claude check

***

Синтаксис правила allow
allow <source_type> <target_type>:<class> <permissions>;

    source_type — це тип процесу або домен, який виконує дію. Це може бути тип програми або процесу, наприклад, httpd_t для веб-сервера.
    target_type — це тип ресурсу (наприклад, файл, директорія, порт), до якого здійснюється доступ.
    class — це клас об'єкта, до якого застосовуються правила доступу. Наприклад, file (файл), dir (директорія), socket, process.
    permissions — це список дозволених операцій, таких як read, write, execute, open, create, залежно від класу об'єкта.

