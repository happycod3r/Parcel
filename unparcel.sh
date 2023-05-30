#!/bin/bash


function unparcel() {

    # Data --> terminal 
    function out() {
        CYAN='\033[0;36m'
        PURPLE='\033[0;35m'
        NC='\033[0m'
        echo -e "${CYAN}[parcel] ${PURPLE}$@${NC}"
        sleep 0.3
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

    # file1.enc ---> file1.txt
    function decrypt-target() {
        local _file bname
        _file="$1"
        bname="$(get-base-file-name $_file)"
        bash src/encrypt.sh -d -i "$_file" -o "${bname}.txt" -k "$(cat encryption.key)"
        sudo rm "$_file"
    }

    function unarc-target() {
        out "--------------------------------"
        local target extension target_dir

        target="$1"
        out "1) target: $target"
        
        target_dir="$(get-target-directory $target)"
        current_dir="current dir: $(pwd)"
        out "2) target: $target"
        target_base="$(get-base-file-name $target)"

        extension=".${target##*.}"
        
        if [[ "$extension" == ".arc" ]]; then
            out "3) target: $target"
            out "target in if statement: $target"
            $BIN/arc xo $target

            target="${target%.*}"
            out "4) target: $target"
            sudo rm "${target}.arc"
            out "5) target: $target"
            out "tb: $target_base" 
            sudo mv "${target_base}.enc" "${target_dir}/${target_base}.enc"
            out "Moving: ${target_base}.enc ----> ${target_dir}/${target_base}.enc"
        fi
        out "--------------------------------"
    }
    function unzip-target() {

        local target
        target="$1"
        target_base="$(get-base-file-name $target)"
        unzip $target 
        if [[ "$target_base" != "$parcel_id" ]]; then
            sudo mv "$target_base" "$parcel_id"
        fi
        sudo rm $target
    }

    function process-files() {
        local directory action
        directory="$1"
        action="$2"
        for file in "$directory"/*; do
            if [ -f "$file" ]; then
                "$action" "$file"
            elif [ -d "$file" ]; then
                # Recursively call process-files for any sub-directories.
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

    local parcel parcel_id ARCHIVED_PARCEL_DIR OPENED_PARCEL_DIR bname new_name action BIN
    
    parcel="$1"
    parcel_id="$(get-base-file-name $parcel)"
    OPENED_PARCEL_DIR="./Opened-Parcels"
    ARCHIVED_PARCEL_DIR="./Parcels"
    BIN="$(pwd)/src/bin"


    if [[ ! -d "$OPENED_PARCEL_DIR" ]]; then
        mkdir "$OPENED_PARCEL_DIR"
    fi
    
    out "$parcel"

    sudo mv "${ARCHIVED_PARCEL_DIR}/${parcel}" "${OPENED_PARCEL_DIR}"

    reverted_parcel_name="$(get-base-file-name $parcel).zip"

    cd "$OPENED_PARCEL_DIR" && sudo mv "$parcel" "$reverted_parcel_name"

    echo "$(pwd)" # Opened-Parcels/

    unzip-target "${parcel_id}.zip"

    action="unzip-target"
    process-zips "$parcel_id" "$action"

    # ------------ GOOD SO FAR BEFORE THIS LINE ------------#
    action="unarc-target"
    process-files "$parcel_id" "$action"

}

unparcel "$1"
