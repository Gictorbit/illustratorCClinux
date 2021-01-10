#!/usr/bin/env bash

source "sharedFuncs.sh"

main() {    

    CMD_PATH="/usr/local/bin/illustrator"
    ENTRY_PATH="/home/$USER/.local/share/applications/illustratorCC.desktop"
    
    notify-send "Illustrator CC" "illustrator uninstaller started" -i "inkscape"

    ask_question "you are uninstalling illustrator cc are you sure?" "N"
    if [ $result == "no" ];then
        echo "Ok good Bye :)"
        exit 0
    fi
    
    #remove illustrator directory
    if [ -d "$SCR_PATH" ];then
        echo "remove illustrator directory..."
        rm -r "$SCR_PATH" || error2 "couldn't remove illustrator directory"
        sleep 4
    else
        echo "illustrator directory Not Found!"
    fi
    
    
    #Unlink command 
    if [ -L "$CMD_PATH" ];then
        echo "remove launcher command..."
        sudo unlink "$CMD_PATH" || error2 "couldn't remove launcher command"
    else
        echo "launcher command Not Found!"
    fi

    #delete desktop entry
    if [ -f "$ENTRY_PATH" ];then
        echo "remove desktop entry...."
        echo "$SCR_PATH"
        rm "$ENTRY_PATH" || error2 "couldn't remove desktop entry"
    else
        echo "desktop entry Not Found!"
    fi

    #delete cache directoy
    if [ -d "$CACHE_PATH" ];then
        echo "--------------------------------"
        echo "all downloaded components are in cache directory and you can use them for illustrator installation next time without wasting internet traffic"
        echo -e "your cache directory is \033[1;36m$CACHE_PATH\e[0m"
        echo "--------------------------------"
        ask_question "would you delete cache directory?" "N"
        if [ "$result" == "yes" ];then
            rm -rf "$CACHE_PATH" || error2 "couldn't remove cache directory"
            show_message2 "cache directory removed."
        else
            echo "nice, you can use downloaded data later for illustrator installation"
        fi
    else
        echo "cache directory Not Found!"    
    fi

}

#parameters [Message] [default flag [Y/N]]
function ask_question() {
    result=""
    if [ "$2" == "Y" ];then
        read -r -p "$1 [Y/n] " response
        if [[ "$response" =~ $(locale noexpr) ]];then
            result="no"
        else
            result="yes"
        fi
    elif [ "$2" == "N" ];then
        read -r -p "$1 [N/y] " response
        if [[ "$response" =~ $(locale yesexpr) ]];then
            result="yes"
        else
            result="no"
        fi
    fi
}

load_paths
main
