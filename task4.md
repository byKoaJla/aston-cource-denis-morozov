# Домашнее задание 4
Написать скрипт (bash, python), который удовлетворяет следующим условиям:
- получает на вход адрес для проверки доступности ресурса, например 
http://app.local.
- при сетевой недоступности ресурса скрипт завершается с ошибкой, иначе 
завершается успешно.

Листинг task4.sh
```
#!/bin/bash
# Сохранение аргумента в переменную.
URL=$1

# Проверка на то, введен ли аргумент. Если нет, то вернуть код ошибки и сообщение.
if [ "$URL" == "" ]; then
    echo "URL address is required!"
    exit 1
fi

# Проверка является ли URL действительно url-адресом. Если нет, то вернуть код ошибки и сообщение.
if [[ $URL =~ ^https?://([^/]+) ]]; then
    URL="$1"
else
    echo "Invalid URL address!"
    exit 1
fi

# Попытка получить статус код от запроса к URL и записать его в переменную error, если же нет доступа, то передать код ошибки '000' в ту же переменную.
error=$(curl -o /dev/null -k -s -w "%{http_code}" "$URL" 2>&1)
# Переменная для получения кода выхода программы.
curl_exec_code=$?

# Проверка, если код не равен 0, значит произошла ошибка подключения. Иначе выводим сообщение, что ресурс доступен с статус-кодом.
if [ $curl_exec_code -ne 0 ]; then
    echo "Error to connection $URL"
    echo "$error"
    exit 1
else 
    echo "The website with url $URL is available. HTTP status: $error"
fi

```
---
Тестирование скрипта:
1. Проверяем, если не введен аргумент (url-адрес).
```
workstation@magicbook:~/bash$ ./task4.sh
URL address is required!
```
2. Проверяем на правильность ввода URL-адреса.
```
workstation@magicbook:~/bash$ ./task4.sh dso
Invalid URL address!
```
3. Проверяем, можем ли мы получить ответ от правильного и доступного URL-адреса.
```
workstation@magicbook:~/bash$ ./task4.sh https://app.loc
The website with url https://app.loc is available. HTTP status: 200
```
4. Проверяем, что получаем ошибку, если вводим правильный URL-адресс, но несуществующий.
```
workstation@magicbook:~/bash$ ./task4.sh https://app
Error to connection https://app
000
```
Что означает, что curl не удалось подключиться к данному ресурсу.