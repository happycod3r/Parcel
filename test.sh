#!/bin/bash

function get-target-directory() { # _file="$1"
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

function make-encryption-key() {
    bash encrypt.sh -g > encryption.key
}

function encrypt-file() { #file="$1"
    local _file enc_file bname
    file="$1"
    echo "encrypting: $file"
    bname="$(get-base-file-name $file)"
    enc_file="${bname}.enc"
    bash encrypt.sh -e -i "$file" -o "$(get-target-directory $file)/${enc_file}" -k "$(cat encryption.key)"
    sudo rm "$file"
}

function process-files() { # directory="$1", action="$2"
    local directory="$1"
    local action="$2"
    # Iterate through all files and directories in the given directory
    for file in "$directory"/*; do
        if [ -f "$file" ]; then
            echo "Processing: $file"
            # Perform the desired action on the file
            "$action" "$file"
        elif [ -d "$file" ]; then
            # Recursively call the function for subdirectories
            process-files "$file" "$action"
        fi
    done
}

function _init() {
    
    make-encryption-key
    action="encrypt-file"
    folder="test1"
    process-files "$folder" "$action"

    #get-target-file-directory "encrypt.sh"
    #make-test-subjects -a
    #clean
}

_init
