#!/bin/bash

function doc-out() {
    echo "- ### $@" >> FUNCTION_CTRL_SHOW.md
}

function parcel() {
    doc-out "parcel()"

    function fatal() {
        CYAN='\033[0;36m'
        RED='\033[0;31m'
        NC='\033[0m'

        echo -e "${CYAN}[parcel]$0: ${RED}fatal error:${CYAN} $@ \nPlease provide file name/s and/or folder name/s to create an encrypted ${CYAN}.parcel archive. \nUsage: ${RED}start <file> <file> <folder>${NC}" >&2
        exit 0
    }

    function parcel-log() { 
        if [[ ! -f "logs/parcel.log" ]]; then
            touch "parcel.log"
            sudo mv "parcel.log" "logs/"
        fi

        echo "$@" >> "logs/parcel.log"
    }
    
    function debug-log() {
        if [[ ! -f "logs/debug.log" ]]; then
            touch "debug.log"
            sudo mv "debug.log" "logs/"
        fi
        
        echo "$@" >> logs/debug.log
    }

    function out() {
        CYAN='\033[0;36m'
        PURPLE='\033[0;35m'
        NC='\033[0m'
        
        echo -e "${CYAN}[parcel] ${PURPLE}$@${NC}"
    }

    function error-out {
        echo -e "$@"
        sleep 1
    }
    
    function write-parcel-data() {
        if [[ ! -f "parcel.data" ]]; then
            touch parcel.data
        fi
        
        echo "$@" >> parcel.data
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

    function gpg-encrypt-target() { 
        local target
        
        target="$1"
        
        gpg --symmetric $target 
        rm "$target"
    }
    
    function make-encryption-key() {
        bash src/encrypt.sh -g > encryption.key
        
        PARCEL_KEY="$(cat -u encryption.key)"
    }

    function encrypt-target() { 
        local target enc_file bname
        
        target="$1"
        bname="$(get-base-file-name $target)"
        extension=".${target##*.}"
        enc_file="${bname}${extension}.enc"
        
        bash src/encrypt.sh -e -i "$target" -o "$(get-target-directory $target)/${enc_file}" -k "$(cat encryption.key)"
        
        rm "$target"
    }

    function arc-target() {
        local bname target file1 file2
        
        target="$1"
        bname="$(get-base-file-name $target)"
        
        ./src/bin/arc ao $bname $target
        
        rm "$target"
        
        file1="${bname}.arc"
        file2="$(get-target-directory $target)/${bname}.arc"
        
        if [[ "$(realpath $file1)" != "$(realpath $file2)" ]]; then
            mv "${bname}.arc" "$(get-target-directory $target)/${bname}.arc"
            return 0
        fi        
    }

    function zip-target() {
        local target
        
        target="$1"
        
        sudo zip -r "./${target}.zip" "$target"
    }

    function process-files() {
        local directory action extension non_extension TARGET_DATA_STRING
        
        directory="$1"
        action="$2"
        extension=".${target##*.}"
        non_extension="${target##*.}/"
        TARGET_DATA_STRING=""
        
        for file in "$directory"/*; do
        
            extension=".${file##*.}"
            non_extension="${file##*.}/"
        
            if [ -f "$file" ]; then
        
                TARGET_DATA_STRING="$file : $extension : $parcel_id : $parcel_name"
                "$action" "$file"
        
            elif [ -d "$file" ]; then
        
                TARGET_DATA_STRING="$file : $non_extension : $parcel_id : $parcel_name"
                process-files "$file" "$action"
        
            fi
            if [[ "$extension" != ".enc" ]]; then
        
                write-parcel-data $TARGET_DATA_STRING
                parcel-log $TARGET_DATA_STRING
        
            fi
        done
    }

    read -p "[parcel]: turn your file/s into a parcel archive. 
    Continue? (yes/no) " answer
    
    if [[ $answer != "yes" ]]; then
        out "Archiving/encrypting aborted."
        exit 0
    fi
    
    local iteration_count targets total_targets current_directory parcel_directory random_suffix parcel_id parcel_name OUTPUT_DIRECTORY PARCEL THIS_DIRECTORY LOG_DIRECTORY extension non_extension PARCEL_DATA_FILE TARGET_DATA_STRING LOG_START_DELIMETER LOG_ENDING_DELIMETER PARCEL_KEY
    
    THIS_DIRECTORY="$(pwd)"
    iteration_count=0
    targets=$@
    total_targets=$#
    current_directory="$(pwd)"
    OUTPUT_DIRECTORY="Parcels/"
    LOG_DIRECTORY="logs/"
    PARCEL_DATA_FILE="parcel.data"
    LOG_START_DELIMETER="--------  $(date)  --------"
    LOG_ENDING_DELIMETER="-------------------- $(date "+%I:%M:%S") -------------------"

    #/////////////////////////////////////////////////////
    #NOTE: NEW ID AND PARCEL NAME ASSIGNMENT.
    
    random_suffix=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
    parcel_id="${random_suffix^^}"
    parcel_name="${parcel_id}.parcel"
    parcel_directory="$parcel_id"
    
    #/////////////////////////////////////////////////////
    #NOTE: THE PARCEL ID AND NAME ARE NOW AVAILABLE FOR USE.
    #/////////////////////////////////////////////////////
    #NOTE: MAKE ALL FILES/FOLDERS FOR THE CURRENT PARCEL HERE.
    
    mkdir -p $parcel_directory
    make-encryption-key
    touch $PARCEL_DATA_FILE
    
    if [[ ! -d $OUTPUT_DIRECTORY ]]; then
        mkdir -p "$OUTPUT_DIRECTORY"
    fi
    if [[ ! -d $LOG_DIRECTORY ]]; then
        mkdir -p "$LOG_DIRECTORY"
    fi
    
    #/////////////////////////////////////////////////////
    #NOTE: Logs shouldn't be used before this point.
    #/////////////////////////////////////////////////////
    #NOTE: ITERATING THROUGH TARGETS BEYOND THIS POINT.
    
    write-parcel-data $LOG_START_DELIMETER
    #write-parcel-data "[$PARCEL_KEY]"
    
    for target in ${targets}; do
    
        extension=".${target##*.}" # For Files.
        non_extension="${target##*.}/" # For directories
    
        if [[ $iteration_count -ne $total_targets ]]; then
    
            #/////////////////////////////////////////////////////
            #NOTE: BEGINNING OF ITERATION.
    
            iteration_count=$((iteration_count + 1))   
    
            if [[ -f "$target" ]]; then
    
                #/////////////////////////////////////////////////////
                #NOTE: ADDING FILES HERE.
    
                TARGET_DATA_STRING="$target : $extension : $parcel_id : $parcel_name"
                encrypt-target "$target"
                target="${target}.enc"
                arc-target "$target"
                _base="$(get-base-file-name $target)"
                target="${_base}.arc"
                sudo mv "$target" "$parcel_directory/"
    
            elif [[ -d "$target" ]]; then
    
                #/////////////////////////////////////////////////////
                #NOTE: ADDING FOLDERS HERE.
    
                TARGET_DATA_STRING="$target : $non_extension : $parcel_id : $parcel_name"
    
                local action
                action="encrypt-target"
                process-files "$target" "$action"
    
                action="arc-target"
                process-files "$target" "$action"
    
                zip-target "$target"
                rm -r "$target"
                mv "${target}.zip" "$parcel_directory/"
            else
    
                #/////////////////////////////////////////////////////
                #NOTE: INVALID FILE/FOLDER OPTIONS HERE.
    
                TARGET_DATA_STRING="$target : [unknown] : $parcel_id : $parcel_name"
                error-out "\n$TARGET_DATA_STRING\n"            
            fi
    
            write-parcel-data $TARGET_DATA_STRING
            continue
        fi
    done
    
    #/////////////////////////////////////////////////////
    #NOTE: LOOP DONE BEYOND THIS. ALL FILES/FOLDERS ADDED TO parcel/
    
    write-parcel-data "$LOG_ENDING_DELIMETER"
    
    #/////////////////////////////////////////////////////
    #NOTE: ANY LAST MINUTE FILES THAT SHOULD GO IN parcel/ GOES HERE.
    
    mv "encryption.key" "$parcel_directory/"
    mv $PARCEL_DATA_FILE "$parcel_directory/"
    
    #/////////////////////////////////////////////////////
    #NOTE: ARCHIVING STARTS HERE.
    
    zip -r "./${parcel_directory}.zip" "$parcel_directory"
    rm -r "$parcel_directory"
    mv ./${parcel_directory}.zip  ./${parcel_name}    
    mv $parcel_name $OUTPUT_DIRECTORY
    PARCEL="$(pwd)/$OUTPUT_DIRECTORY${parcel_name}"
}

parcel $@
