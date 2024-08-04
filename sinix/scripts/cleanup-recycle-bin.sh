#!/bin/sh
recyclePath="/mnt/storage/files/.recycle"
maxStoreDays="60"
find $recyclePath -name "*" -ctime +$maxStoreDays -exec rm {} \;