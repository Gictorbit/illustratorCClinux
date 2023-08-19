#! /usr/bin/env bash

source "sharedFuncs.sh"

function main() {
    mkdir -p $SCR_PATH
    mkdir -p $CACHE_PATH
    
    setup_log "================| script executed |================"
    
    #make sure wine package is already installed
    package_installed wine
    package_installed md5sum

    RESOURCES_PATH="$SCR_PATH/resources"
    WINE_PREFIX="$SCR_PATH/prefix"
    ILLDIR="$SCR_PATH/"
    
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
    
    sleep 10
    
    if [ -f "$WINE_PREFIX/user.reg" ];then
        #add dark mod
        set_dark_mod
    else
        error "user.reg Not Found :("
    fi

    #create resources directory we extract downloaded file into this and will be deleted after installation more like /tmp
    rmdir_if_exist $RESOURCES_PATH

    #install illustrator
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
    sleep 10
}

function install_illustratorCC() {
    local filename="illustratorCC17.tgz"
    local filemd5="d470b541cef1339a66ea33a998801f83"
    # local filelink="http://127.0.0.1:4050/illustratorCC17.tgz"
    local filelink="https://downloads.runebase.io/illustratorCC17.tgz"
    local filepath="$CACHE_PATH/$filename"

    download_component $filepath $filemd5 $filelink $filename

    echo "===============| IllustratorCC17 |===============" >> "$SCR_PATH/wine-error.log"

    show_message "extract IllustratorCC..."
    rmdir_if_exist "$SCR_PATH/IllustratorCC17"
    tar -xzf "$filepath" -C "$SCR_PATH" || error "sorry something went wrong during illustrator installation"

    show_message "install Illustrator..."

    show_message "IllustratorCC v17 x64 installed..."
    unset filename filemd5 filelink filepath
}

check_arg $@
save_paths
main
