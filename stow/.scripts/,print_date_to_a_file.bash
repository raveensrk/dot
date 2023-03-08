#!/usr/bin/env bash

> ~/.tmp/printing_date.txt

while :; do
    sleep 1
    date >> ~/.tmp/printing_date.txt
done
