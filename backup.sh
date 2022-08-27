#!/usr/bin/bash
time 7z a -mmt mine.7z bungee/ loby/ mine/ Makefile backup.sh
#rclone -P copy mine.7z mback:mine/sex-club/$(date '+%Y-%m-%d')/mine.7z
