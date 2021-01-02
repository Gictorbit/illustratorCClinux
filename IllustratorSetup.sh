#! /usr/bin/env bash

function main() {
    mkdir -p $SCR_PATH
    mkdir -p $CACHE_PATH
    
    setup_log "================| script executed |================"
    
    #make sure aria2c and wine package is already installed
    package_installed aria2c
    package_installed wine
    package_installed md5sum

    RESOURCES_PATH="$SCR_PATH/resources"
    WINE_PREFIX="$SCR_PATH/prefix"
    
    #create new wine prefix for illustrator
    rmdir_if_exist $WINE_PREFIX
    
    #export necessary variable for wine
    export_var

    #config wine prefix and install mono and gecko automatic
    echo -e "\033[1;93mplease install mono and gecko packages then click on OK button\e[0m"
    winecfg 2> "$SCR_PATH/wine-error.log"
    if [ $? -eq 0 ];then
        show_message "prefix configured..."
        sleep 5
    else
        error "prefix config failed :("
    fi
    
    if [ -f "$WINE_PREFIX/user.reg" ];then
        #add dark mod
        set_dark_mod
    else
        error "user.reg Not Found :("
    fi

    #create resources directory we extract downloaded file into this and will be deleted after installation more like /tmp
    rmdir_if_exist $RESOURCES_PATH

    #install photoshop
    sleep 3
    install_illustratorCC
    sleep 5

    if [ -d $RESOURCES_PATH ];then
        show_message "deleting resources folder"
        rm -rf $RESOURCES_PATH
    else
        error "resources folder Not Found"
    fi

    launcher
    show_message "Almost finished..."
    sleep 15


}

function launcher() {
    #create launcher script
    local launcher_path="$PWD/launcher.sh"
    local launcher_dest="$SCR_PATH/launcher"

    #mkdir launcher dest and remove it if exist 
    rmdir_if_exist "$launcher_dest"

    if [ -f "$launcher_path" ];then
        show_message "launcher.sh detected..."
        
        cp "$launcher_path" "$launcher_dest" || error "can't copy launcher"
        
        sed -i "s|aipath|$SCR_PATH|g" "$launcher_dest/launcher.sh" && sed -i "s|aicache|$CACHE_PATH|g" "$launcher_dest/launcher.sh" || error "can't edit launcher script"
        
        chmod +x "$SCR_PATH/launcher/launcher.sh" || error "can't chmod launcher script"
    else
        error "launcher.sh Note Found"
    fi

    #create desktop entry
    local desktop_entry="$PWD/illustratorCC.desktop"
    local desktop_entry_dest="/home/$USER/.local/share/applications/illustratorCC.desktop"

    if [ -f "$desktop_entry" ];then
        show_message "desktop entry detected..."
       
        #delete desktop entry if exists
        if [ -f "$desktop_entry_dest" ];then
            show_message "desktop entry exist deleted..."
            rm "$desktop_entry_dest"
        fi
        cp "$desktop_entry" "$desktop_entry_dest" || error "can't copy desktop entry"
        sed -i "s|aipath|$SCR_PATH|g" "$desktop_entry_dest" || error "can't edit desktop entry"
    else
        error "desktop entry Not Found"
    fi

    #change photoshop icon of desktop entry
    local entry_icon="$PWD/images/AiIcon.png"
    local launch_icon="$launcher_dest/AiIcon.png"

    cp "$entry_icon" "$launcher_dest" || error "can't copy icon image" 
    sed -i "s|illustratoricon|$launch_icon|g" "$desktop_entry_dest" || error "can't edit desktop entry"
    sed -i "s|illustratoricon|$launch_icon|g" "$launcher_dest/launcher.sh" || error "can't edit launcher script"

    #create photoshop command
    show_message "create illustrator command..."
    if [ -f "/usr/local/bin/illustrator" ];then
        show_message "illustrator command exist deleted..."
        sudo rm "/usr/local/bin/illustrator"
    fi
    sudo ln -s "$SCR_PATH/launcher/launcher.sh" "/usr/local/bin/illustrator" || error "can't create illustrator command"

    unset desktop_entry desktop_entry_dest launcher_path launcher_dest
}

function install_illustratorCC() {
    local filename="illustratorCC17.tgz"
    local filemd5="d470b541cef1339a66ea33a998801f83"
    # local filelink="http://127.0.0.1:4050/illustratorCC17.tgz"
    local filelink="https://victor.poshtiban.io/p/gictor/illustratorCC/illustratorCC17.tgz"
    local filepath="$CACHE_PATH/$filename"

    download_component $filepath $filemd5 $filelink $filename

    echo "===============| IllustratorCC17 |===============" >> "$SCR_PATH/wine-error.log"

    show_message "extract IllustratorCC..."
    tar -xzf "$filepath" -C "$SCR_PATH" || error "sorry something went wrong during illustrator installation"

    show_message "install Illustrator..."

    show_message "IllustratorCC v17 x64 installed..."
    unset filename filemd5 filelink filepath
}

#parameters is [PATH] [CheckSum] [URL] [FILE NAME]
function download_component() {
    local tout=0
    while true;do
        if [ $tout -ge 2 ];then
            error "sorry something went wrong during download $4"
        fi
        if [ -f $1 ];then
            local FILE_ID=$(md5sum $1 | cut -d" " -f1)
            if [ "$FILE_ID" == $2 ];then
                show_message "\033[1;36m$4\e[0m detected"
                return 0
            else
                show_message "md5 is not match"
                rm $1 
            fi
        else   
            show_message "downloading $4 ..."
            aria2c -c -x 8 -d $CACHE_PATH -o $4 $3
            if [ $? -eq 0 ];then
                notify-send "$4 download completed" -i "download"
            fi
            ((tout++))
        fi
    done    
}

function set_dark_mod() {
    echo " " >> "$WINE_PREFIX/user.reg"
    local colorarray=(
        '[Control Panel\\Colors] 1491939580'
        '#time=1d2b2fb5c69191c'
        '"ActiveBorder"="49 54 58"'
        '"ActiveTitle"="49 54 58"'
        '"AppWorkSpace"="60 64 72"'
        '"Background"="49 54 58"'
        '"ButtonAlternativeFace"="200 0 0"'
        '"ButtonDkShadow"="154 154 154"'
        '"ButtonFace"="49 54 58"'
        '"ButtonHilight"="119 126 140"'
        '"ButtonLight"="60 64 72"'
        '"ButtonShadow"="60 64 72"'
        '"ButtonText"="219 220 222"'
        '"GradientActiveTitle"="49 54 58"'
        '"GradientInactiveTitle"="49 54 58"'
        '"GrayText"="155 155 155"'
        '"Hilight"="119 126 140"'
        '"HilightText"="255 255 255"'
        '"InactiveBorder"="49 54 58"'
        '"InactiveTitle"="49 54 58"'
        '"InactiveTitleText"="219 220 222"'
        '"InfoText"="159 167 180"'
        '"InfoWindow"="49 54 58"'
        '"Menu"="49 54 58"'
        '"MenuBar"="49 54 58"'
        '"MenuHilight"="119 126 140"'
        '"MenuText"="219 220 222"'
        '"Scrollbar"="73 78 88"'
        '"TitleText"="219 220 222"'
        '"Window"="35 38 41"'
        '"WindowFrame"="49 54 58"'
        '"WindowText"="219 220 222"'
    )
    for i in "${colorarray[@]}";do
        echo "$i" >> "$WINE_PREFIX/user.reg"
    done
    show_message "set dark mode for wine..." 
    unset colorarray
}

function export_var() {
    export WINEPREFIX="$WINE_PREFIX"
    show_message "wine variables exported..."
}

function package_installed() {
    which $1 &> /dev/null
    local pkginstalled="$?"
    if [ "$pkginstalled" -eq 0 ];then
        show_message "package\033[1;36m $1\e[0m is installed..."
    else
        warning "package\033[1;33m $1\e[0m is not installed.\nplease make sure it's already installed"
        ask_question "would you continue?" "N"
        if [ "$question_result" == "no" ];then
            echo "exit..."
            exit 5
        fi
    fi
}

function check_arg() {
    while getopts "hd:c:" OPTION; do
        case $OPTION in
        d)
            PARAMd="$OPTARG"
            SCR_PATH=$(readlink -f "$PARAMd")
            
            dashd=1
            echo "install path is $SCR_PATH"
            ;;
        c)
            PARAMc="$OPTARG"
            CACHE_PATH=$(readlink -f "$PARAMc")
            dashc=1
            echo "cahce is $CACHE_PATH"
            ;;
        h)
            usage
            ;; 
        *)
            echo "wrong argument"
            exit 1
            ;;
        esac
    done
    shift $(($OPTIND - 1))

    if [[ $# != 0 ]];then
        usage
        error2 "unknown argument"
    fi

    if [[ $dashd != 1 ]] ;then
        echo "-d not define default directory used..."
        SCR_PATH="$HOME/.illustratorCC17"
    fi

    if [[ $dashc != 1 ]];then
        echo "-c not define default directory used..."
        CACHE_PATH="$HOME/.cache/illustratorCC17"
    fi
}

function rmdir_if_exist() {
    if [ -d "$1" ];then
        rm -rf "$1"
        show_message "\033[0;36m$1\e[0m directory exists deleting it..."
    fi
    mkdir "$1"
    show_message "create\033[0;36m $1\e[0m directory..."
}

function setup_log() {
    echo -e "$(date) : $@" >> $SCR_PATH/setuplog.log
}

function show_message() {
    echo -e "$@"
    setup_log "$@"
}

function error() {
    echo -e "\033[1;31merror:\e[0m $@"
    setup_log "$@"
    exit 1
}

function error2() {
    echo -e "\033[1;31merror:\e[0m $@"
    exit 1
}

function warning() {
    echo -e "\033[1;33mWarning:\e[0m $@"
    setup_log "$@"
}

function warning2() {
    echo -e "\033[1;33mWarning:\e[0m $@"
}

function show_message2() {
    echo -e "$@"
}

function usage() {
    echo "USAGE: [-c cache directory] [-d installation directory]"
}

function save_paths() {
    local datafile="$HOME/.aidata.txt"
    echo "$SCR_PATH" > "$datafile"
    echo "$CACHE_PATH" >> "$datafile"
    unset datafile
}

check_arg $@
save_paths
main