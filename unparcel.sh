#!/bin/bash


function unparcel() {

    # Data --> terminal 
    function out() {
        CYAN='\033[0;36m'
        PURPLE='\033[0;35m'
        NC='\033[0m'
        echo -e "${CYAN}[parcel] ${PURPLE}$@${NC}"
        sleep 1
    }

    # Data --> terminal
    function error-out {
        CYAN='\033[0;36m'
        RED='\033[0;31m'
        NC='\033[0m'
        echo -e "${CYAN}[parcel]${RED}$@${NC}"
        sleep 1
    }

    # Returns my/file/path/file.txt
    print-file-fqp() {
        local file="$1"
        echo "File: $file"
    }

    # Returns: my/target/files/directory
    function get-target-directory() {
        local _file _file_fqp _file_path
        _file="$1"
        _file_fqp="$(readlink -f $_file)"
        _file_path=$(echo "${_file_fqp%/*}")
        echo "$_file_path"
    }

    function get-base-file-name() {
        local _file bname
        _file="$1"
        bname=$(echo "$_file" | awk '{gsub(/.*[/]|[.].*/, "", $0)} 1')
        echo "$bname"
    }

    # file1.enc.gpg ---> file1.enc
    function gpg-decrypt-target() {
        local _file
        _file="$1"
        # Goes back to .enc to be decrypted by internal encryption.
        bname="$(get-base-file-name $_file)"
        echo "$(gpg --decrypt $_file)" >> "${bname}.enc"
        # probably have to do the following instead so the .enc goes back where it belongs like I did in encrypt-file:
        # echo "$(gpg --decrypt $_file)" >> "(get-target-directory $file)${bname}.enc"
    }

    # file1.enc ---> file1.txt
    function decrypt-target() {
        local _file bname
        _file="$1"
        bname="$(get-base-file-name $_file)"
        bash src/encrypt.sh -d -i "$_file" -o "${bname}.txt" -k "$(cat encryption.key)"
        sudo rm "$_file"
    }

    function unarc-target() {
        local target
        target="$1"
    }

    function unzip-target() {
        local target
        target="$1"
        unzip -o "$target" -d "open_parcel"
    }

    local parcel parcel_id ARCHIVED_PARCEL_DIR OPENED_PARCEL_DIR bname new_name 
    parcel="$1"
    parcel_id="$(get-base-file-name $parcel)"
    OPENED_PARCEL_DIR="./Opened-Parcels"
    ARCHIVED_PARCEL_DIR="./Parcels"
    if [[ ! -d "$OPENED_PARCEL_DIR" ]]; then
        mkdir "$OPENED_PARCEL_DIR"
    fi
    echo "current: $(pwd)"
    echo "archived ${ARCHIVED_PARCEL_DIR}/${parcel} : $OPENED_PARCEL_DIR"
    sudo mv "${ARCHIVED_PARCEL_DIR}/${parcel}" "$OPENED_PARCEL_DIR"
    bname="$(get-base-file-name $parcel)"
    new_name="${bname}.zip"     
    sudo mv "$parcel" "$new_name"
    parcel="$new_name"
    unzip "$parcel"
    sudo rm "$new_name"
    unzip "${OPENED_PARCEL_DIR}/${parcel_id}/*.zip"
    sudo rm "${OPENED_PARCEL_DIR}/${parcel_id}/*.zip"
}

unparcel "$1"
