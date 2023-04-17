#!/bin/bash
lockfile=/tmp/script.pid
if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null; 
then
     trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
     while true
     do
         TZ=UTC
         d=`date +%d"/"%b"/"%Y":"%H  -d "1 hour ago"`
         derr=`date +%Y"/"%m"/"%d" "%H   -d "1 hour ago"`
         echo "Информация по логированию NGINX за период `date +%d"."%m"."%Y" "%H":00:00 - "%H":59:59"  -d "1 hour ago" -d "1 hour ago"`"
         echo "Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска:"
         awk -v d="$d" '$0 ~ d {print $0}' /var/log/nginx/access.log | awk '{ ipcount[$1]++ } END { for (i in ipcount) { printf "IP:%13s ~ %d times\n", i, ipcount[i] } }' | sort -t '~' -k 2,2 -rn
         echo "--------------------------------------------------------------------------------------"
         echo "Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска:"
         awk -v d="$d" '$0 ~ d {print $0}' /var/log/nginx/access.log | awk '{ urlcount[$7]++ } END { for (i in urlcount) { printf "URL:%13s ~ %d times\n", i, urlcount[i] } }' | sort -t '~' -k 2,2 -rn
         echo "--------------------------------------------------------------------------------------"
         echo "Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска:"
         awk -v d="$d" '$0 ~ d {print $0}' /var/log/nginx/access.log | awk '{ codecount[$9]++ } END { for (i in codecount) { printf "ERROR_CODE:%13s ~ %d times\n", i, codecount[i] } }' | sort -t '~' -k 2,2 -rn
         echo "--------------------------------------------------------------------------------------"
         echo "Ошибки веб-сервера/приложения c момента последнего запуска:"
         awk -v d="$derr" '$0 ~ d {print $0}' /var/log/nginx/error.log 
         sleep 10
         kill $$
     done
    rm -f "$lockfile"
    trap - INT TERM EXIT
else
    echo "Failed to acquire lockfile: $lockfile."
    echo "Held by $(cat $lockfile)"
fi