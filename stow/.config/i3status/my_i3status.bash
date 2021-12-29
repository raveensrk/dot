#!/bin/bash

# shell script to prepend i3status with more stuff


                                                
# mystuff | ,[{"name":"memory","markup":"none","full_text":"3.5 GiB | 11.8 GiB"},{"name":"load","markup":"none","full_text":"1.61"},{"name":"tztime","instance":"local","markup":"none","full_text":"2021-11-21 Sun 22:08:46 PM"},{"name":"ipv6","color":"#50FA7B","markup":"none","full_text":"2405:201:e00b:801a:80f3:4df:dfff:af51"},{"name":"wireless","instance":"wlp4s0","color":"#50FA7B","markup":"none","full_text":"W: ( 70% at JioFiber-DtmNN_5G) 192.168.29.10"},{"name":"ethernet","instance":"_first_","color":"#FF5555","markup":"none","full_text":"E: down"},{"name":"disk_info","instance":"/","markup":"none","full_text":"189.1 GiB"},{"name":"tztime","instance":"local","markup":"none","full_text":"2021-11-21 Sun 22:08:46 PM"}]


i3status | while :
do
    read line
    #if [[  $line =~ "{\"version\":1}" ]]; then
    #    echo $line +++ 1
    #elif [[  $line == "[" ]]; then
    #    echo $line +++ 2
    #elif [[  $line =~ ",[{" ]]; then
    #    echo $line +++ 4
    if [[  $line =~ ",[" ]]; then
        echo ",[{\"name\":\"date\",\"markup\":\"none\",\"full_text\":\"$(date)\"},${line#,[}" || exit 1
    else
        echo $line
    fi

done

