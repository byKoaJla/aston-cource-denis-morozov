# Домашнее задание 3
Написать скрипт, который удовлетворяет следующим условиям:
- **создает папку /opt/app**
- **создает файл /opt/app/log.txt**
- **каждые 17 секунд записывает в файл /opt/app/log.txt случайную строку**
- **длиной до 20 символов (каждая итерация - с новой строки).**

### Решение задачи.
1. Создание файла task3.sh
Листинг task3.sh
```
#!/bin/bash

DIR="/opt/app" # переменная для хранение пути до директории.

# Проверка существует ли директория и файл, если его нет, то создать его.
if [ ! -d "$DIR" ] && [ ! -f "$DIR/log.txt" ]; then
    sudo mkdir -p "$DIR"
    sudo touch "$DIR/log.txt"
fi

# Список символов для генерации случайного значения.
chars="1234567890-=/+@#$%^&*qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"

# Запуск бесконечного цикла, который каждые 17 секунд создается запись в файл log.txt.
while true; do
    # Создает случайную строку посредством RANDOM на 19 символов.
    for i in {1..19}; do
        echo -n "${chars:RANDOM%${#chars}:1}" | sudo tee -a "$DIR/log.txt" > /dev/null
    done
    echo "" | sudo tee -a "$DIR/log.txt" > /dev/null
    sleep 17
done
```
2. Дать разрешение для исполнения файла
```
chmod 711 /task3.sh # -rwx--x--x
```
3. Проверяем, что права были применены
```
workstation@magicbook:~$ ls -l /home/workstation/bash/task3.sh
-rwx--x--x 1 workstation workstation 431 Aug  4 15:52 /home/workstation/bash/task3.sh
```
4. Тестирование скрипта
```
workstation@magicbook:~$  /home/workstation/bash/task3.sh 
```
```
workstation@magicbook:~$ cat /opt/app/log.txt
zobdX+OwX40N0CoNgR@
```
```
workstation@magicbook:~$ cat /opt/app/log.txt | wc -l
1
```
5. Проверяем через 1 минуту
```
workstation@magicbook:~$ cat /opt/app/log.txt | wc -l
4
```
6. Данный скрипт соответствует условию, он создает (если ранее не существовало) директорию ```/opt/app``` и файл ```log.txt```. Каждые 17 секунд создает новую запись в файл ```/opt/app/log.txt```.

# Дополнительное задание.
- **добавить скрипт в "автозагрузку" - после перезапуска 
операционной системы скрипт должен стартовать автоматически.**
---
### Решение: 
1. Для решения я использовал ```systemd``` путем создания службы:
```
workstation@magicbook:~$ vi /etc/systemd/system/startup.service
```
Листинг startup.service
```
[Unit]
Description=Авто запуск скрипта записи в лог

[Service]
Type=simple
ExecStart=/home/workstation/bash/task3.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
                         
```
2. Перезагружаем службы
```
workstation@magicbook:~$ sudo systemctl daemon-reload
```
3. Включение моей службы в автозапуск
```
workstation@magicbook:~$ sudo systemctl enable startup.service
```
4. Проверка сервиса (путем запуска его немедленно)
```
workstation@magicbook:~$ sudo systemctl start startup.service
```
```
workstation@magicbook:~$ sudo systemctl status startup.service
```
Вывод проверки службы:
```
● startup.service - Авто запуск скрипта записи в лог
     Loaded: loaded (/etc/systemd/system/startup.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-08-04 16:04:52 +03; 49min ago
   Main PID: 5487 (task3.sh)
      Tasks: 2 (limit: 9344)
     Memory: 808.0K (peak: 7.0M)
        CPU: 19.378s
     CGroup: /system.slice/startup.service
             ├─ 5487 /bin/bash /home/workstation/bash/task3.sh
             └─16222 sleep 17
```
5. Проверка автозапуска (путем перезагрузки системы)
```
workstation@magicbook:~$ sudo systemctl status startup.service
```
Вывод проверки службы:
```
● startup.service - Авто запуск скрипта записи в лог
     Loaded: loaded (/etc/systemd/system/startup.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-08-04 16:04:52 +03; 52min ago
   Main PID: 5487 (task3.sh)
      Tasks: 2 (limit: 9344)
     Memory: 860.0K (peak: 7.0M)
        CPU: 20.581s
     CGroup: /system.slice/startup.service
             ├─ 5487 /bin/bash /home/workstation/bash/task3.sh
             └─16974 sleep 17
```
---
- **настроить ротацию log-файла с помощью logrotate**
---
### Решение:
1. Создание файла /etc/logrotate.d/app-log
Листинг /etc/logrotate.d/app-log.txt
```
/opt/app/log.txt {
    daily                  # Выполнять ротацию каждый день
    rotate 7               # Хранить 7 ратаций (по 1 ратации на день)
    notifempty             # не ротировать пустой файл
    compress               # сжимать старые логи gzip-ом
    delaycompress          # сжимать файлы со старой ротацией, чтобы последний был доступен без сжатия
    create 644 root root   # создавать новый файл с правами 644 (-rw-r--r--), владельцем root
    sharedscripts          # запускать скрипты один раз для всех файлов
}

```
2. Тестирование logrotate через ```--debug```
```
workstation@magicbook:~$ sudo logrotate --debug /etc/logrotate.conf
```
Вывод:
Видим, что наш файл конфигурации прочитан и нет ошибок.
```
...
reading config file app-log
...
```
Видим, что ротация работает в отношении /opt/app/log.txt
```
rotating pattern: /opt/app/log.txt  after 1 days (7 rotations)
empty log files are not rotated, old logs are removed
switching euid from 0 to 0 and egid from 0 to 4 (pid 19026)
considering log /opt/app/log.txt
  Now: 2025-08-04 17:06
  Last rotated at 2025-08-04 17:05
  log does not need rotating (log has already been rotated)
switching euid from 0 to 0 and egid from 4 to 0 (pid 19026)
```