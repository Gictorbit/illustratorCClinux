#!/usr/bin/env bash
if [ $# -ne 0 ];then
    echo "I have no parameters just run the script without arguments"
    exit 1
fi

notify-send "Illustrator CC" "Illustrator CC launched." -i "illustratoricon"

SCR_PATH="aipath"
CACHE_PATH="aicache"

WINE_PREFIX="$SCR_PATH/prefix"
 
export WINEPREFIX="$WINE_PREFIX"

wine "$SCR_PATH/IllustratorCC17/IllustratorCC64.exe"


