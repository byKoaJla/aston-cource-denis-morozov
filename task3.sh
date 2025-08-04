#!/bin/bash

DIR="/opt/app"

if [ ! -d "$DIR" ] && [ ! -f "$DIR/log.txt" ]; then
    sudo mkdir -p "$DIR"
    sudo touch "$DIR/log.txt"
fi


chars="1234567890-=/+@#$%^&*qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
while true; do
    for i in {1..19}; do
        echo -n "${chars:RANDOM%${#chars}:1}" | sudo tee -a "$DIR/log.txt" > /dev/null
    done
    echo "" | sudo tee -a "$DIR/log.txt" > /dev/null
    sleep 17
done

