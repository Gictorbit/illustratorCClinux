#! /usr/bin/env bash

source "sharedFuncs.sh"

function resetIllustrator() {
    load_paths
    show_message2 "reset illustrator..."
    resetDIR="$SCR_PATH/IllustratorCC17/Data"
    
    if [ -d "$resetDIR" ];then
        show_message2 "reset dir found..."
        rm -rf "$resetDIR" || error2 "illustrator error failed"
        echo "illustrator reset successfully."
    else
        error2 "directory not exist"
    fi
}
resetIllustrator