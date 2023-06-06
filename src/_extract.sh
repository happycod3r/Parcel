#!/bin/bash

function _extract() {

    function out() {
        CYAN='\033[0;36m'
        PURPLE='\033[0;35m'
        NC='\033[0m'
        echo -e "${CYAN}[parcel] ${PURPLE}$@${NC}"
        sleep 0.3
    }

    function error-out {
        CYAN='\033[0;36m'
        RED='\033[0;31m'
        NC='\033[0m'
        echo -e "${CYAN}[parcel]${RED}$@${NC}"
        sleep 1
    }

    function get-target-directory() {
        local target target_fqp target_path
        target="$1"
        target_fqp="$(readlink -f $target)"
        target_path=$(echo "${target_fqp%/*}")
        echo "$target_path"
    }

    function get-base-file-name() {
        local _file bname
        _file="$1"
        bname=$(echo "$_file" | awk '{gsub(/.*[/]|[.].*/, "", $0)} 1')
        echo "$bname"
    }

    function decrypt-target() {
        local target extension parcel_id parcel_dir parcel_data_path target_without_enc_ext bname

        target="$1"
        extension=".${target##*.}"
        parcel_id="$2"
        parcel_data_path="$(pwd)/${parcel_id}/parcel.data"
        target_without_enc_ext="${target%.enc}"

        if [[ -z "$parcel_id" ]]; then
            parcel_id="$(echo "$target" | cut -d "/" -f1)"
        fi
        
        if [[ "$extension" == ".enc" ]]; then
            bname="$(get-base-file-name $target)" # f1
            parcel_dir="$(pwd)/${parcel_id}" 
            bash "$SRC/encrypt.sh" -d -i "$target" -o "$target_without_enc_ext" -k "$(cat $parcel_dir/encryption.key)"
            rm "$target"
        fi
    }
    
    function unarc-target() {
        local target extension target_dir
    
        target="$1"
        target_dir="$(get-target-directory $target)"
        target_base="$(get-base-file-name $target)"
        extension=".${target##*.}"

        if [[ "$extension" == ".arc" ]]; then
            $BIN/arc xo $target
            target="${target%.*}"
            rm "${target}.arc"
            mv *.enc $target_dir
        fi
    }

    function unzip-target() {
        local target
        target="$1"
        target_base="$(get-base-file-name $target)"
        unzip $target 
        if [[ "$target_base" != "$parcel_id" ]]; then
            mv "$target_base" "$parcel_id"
        fi
        rm $target
    }

    function process-files() {
        local directory action
        directory="$1"
        action="$2" 
        if [[ "$action" == "decrypt-target" ]]; then
            action_arg="$3"
            for file in "$directory"/*; do
                if [ -f "$file" ]; then
                    "$action" "$file" "$action_arg"
                elif [ -d "$file" ]; then
                    process-files "$file" "$action" "$action_arg"
                fi
            done
        fi

        for file in "$directory"/*; do
            if [ -f "$file" ]; then
                "$action" "$file"
            elif [ -d "$file" ]; then
                process-files "$file" "$action"
            fi
        done
    }

    function process-zips() {
        directory="$1"
        action="$2"
        for target in "$directory"/*; do
            extension=".${target##*.}"
            if [ -f "$target" ]; then
                if [[ "$extension" == ".zip" ]]; then
                    "$action" "$target"
                    continue
                fi
            elif [[ -d "$target" ]]; then
                process-zips "$target" "$action"
            fi
        done
    }

    local parcel parcel_id ARCHIVED_PARCEL_DIR OPENED_PARCEL_DIR bname new_name action BIN SRC
    
    parcel="$1"
    parcel_id="$(get-base-file-name $parcel)"
    OPENED_PARCEL_DIR="./Opened-Parcels"
    ARCHIVED_PARCEL_DIR="./Parcels"
    SRC="$(pwd)/src"
    BIN="$(pwd)/src/bin"

    if [[ ! -d "$OPENED_PARCEL_DIR" ]]; then
        mkdir -p "$OPENED_PARCEL_DIR"
    fi

    sudo mv "${ARCHIVED_PARCEL_DIR}/${parcel}" "${OPENED_PARCEL_DIR}"

    reverted_parcel_name="$(get-base-file-name $parcel).zip"

    cd "$OPENED_PARCEL_DIR" && sudo mv "$parcel" "$reverted_parcel_name"

    unzip-target "${parcel_id}.zip"

    action="unzip-target"
    process-zips "$parcel_id" "$action"

    action="unarc-target"
    process-files "$parcel_id" "$action"

    action="decrypt-target"
    action_arg="$parcel_id"
    process-files "$parcel_id" "$action" "$action_arg"

}

_extract "$1"
