# Bash
Для выполнения этого действия требуется установить приложением git:
`git clone https://github.com/altyn-kenzhebaev/bash-hw9.git`
В текущей директории появится папка с именем репозитория. В данном случае bash-hw9. Ознакомимся с содержимым:
```
cd bash-hw9
ls -l
README.md 
script.sh 
vm_prepare.sh
Vagrantfile  
```
Здесь:
- README.md - файл с данным руководством
- Vagrantfile - файл описывающий виртуальную инфраструктуру для `Vagrant`
- script.sh - скрипт по выводу логов
- vm_prepare.sh - скрипт по конфигурации виртуальной машины
Запускаем ВМ:
```
vagrant up
```
# vm_prepare.sh
Данный скрипт подготавливает ВМ, устанавливает веб-сервер, утилиты отправки электронных сообщений, добавляет строку в crontab
```
#!/bin/bash
yum install epel-release -y
yum install nginx mailx -y
systemctl --now enable nginx
echo "0 * * * * root /vagrant/script.sh | mail -s 'Логирование NGINX' root@localhost" >> /etc/crontab
systemctl reload crond
curl http://localhost > /dev/null
curl http://localhost/test.php > /dev/null
```
# script.sh
Скрипт предотвращает запуск 2-х экземпляровв блоке:
```
lockfile=/tmp/script.pid
if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null; 
then
     trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
     while true
     do
     ...
     done
    rm -f "$lockfile"
    trap - INT TERM EXIT
else
    echo "Failed to acquire lockfile: $lockfile."
    echo "Held by $(cat $lockfile)"
fi
```
Используем 2 переменные связанные форматами дат логирования в access.log и error.log:
```
d=`date +%d"/"%b"/"%Y":"%H  -d "1 hour ago"`
derr=`date +%Y"/"%m"/"%d" "%H   -d "1 hour ago"`
```
В письме прописан обрабатываемый временной диапазон:
```
echo "Информация по логированию NGINX за период `date +%d"."%m"."%Y" "%H":00:00 - "%H":59:59"  -d "1 hour ago" -d "1 hour ago"`"
```
Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта:
```
echo "Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска:"
awk -v d="$d" '$0 ~ d {print $0}' /var/log/nginx/access.log | awk '{ ipcount[$1]++ } END { for (i in ipcount) { printf "IP:%13s ~ %d times\n", i, ipcount[i] } }' | sort -t '~' -k 2,2 -rn
```
Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта:
```
echo "Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска:"
awk -v d="$d" '$0 ~ d {print $0}' /var/log/nginx/access.log | awk '{ urlcount[$7]++ } END { for (i in urlcount) { printf "URL:%13s ~ %d times\n", i, urlcount[i] } }' | sort -t '~' -k 2,2 -rn

```
Ошибки веб-сервера/приложения c момента последнего запуска:
```
echo "Ошибки веб-сервера/приложения c момента последнего запуска:"
awk -v d="$derr" '$0 ~ d {print $0}' /var/log/nginx/error.log 
```
Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта:
```
echo "Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска:"
awk -v d="$d" '$0 ~ d {print $0}' /var/log/nginx/access.log | awk '{ codecount[$9]++ } END { for (i in codecount) { printf "ERROR_CODE:%13s ~ %d times\n", i, codecount[i] } }' | sort -t '~' -k 2,2 -rn
```