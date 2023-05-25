#!/bin/bash


function parcel() {

    # Data --> parcel.log
    function parcel-log() {
        if [[ ! -f "parcel.log" ]]; then
            touch "parcel.log"
        fi
        echo "$@" >> parcel.log
    }
    # Data --> debug.log
    function debug-log() {
        if [[ ! -f "debug.log" ]]; then
            touch "debug.log"
        fi
        echo "$@" >> debug.log
    }
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
    # Data --> parcel.data
    function write-parcel-data() {
        if [[ ! -f "parcel.data" ]]; then
            touch parcel.data
        fi
        echo "$@" >> parcel.data
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

    function encrypt-file() {
        local _file bname
        _file="$1"
        bname="$(get-base-file-name $_file)"
        bash encrypt.sh -e -i "$_file" -o "${bname}.enc" -k "$(cat encryption.key)"
        sudo rm "$_file"
    }

    function decrypt-file() {
        local _file bname
        _file="$1"
        bname="$(get-base-file-name $_file)"
        bash encrypt.sh -d -i "$_file" -o "${bname}.txt" -k "$(cat encryption.key)"
        sudo rm "$_file"
    }

    # ask the user if they want to continue.
    read -p "[parcel]: turn your file/s into a parcell archive. 
    Continue? (yes/no) " answer
    
    if [[ $answer != "yes" ]]; then
        out "Script aborted."
        exit 0
    fi 
    
    local iteration_count targets total_targets current_directory parcel_directory random_suffix parcel_id parcel_name OUTPUT_DIRECTORY PARCEL THIS_DIRECTORY extension non_extension PARCEL_DATA_FILE TARGET_DATA_STRING LOG_START_DELIMETER LOG_ENDING_DELIMETER
    
    THIS_DIRECTORY="$(pwd)"
    iteration_count=0
    targets=$@
    total_targets=$#
    current_directory="$(pwd)"
    parcel_directory="./parcel"
    PARCEL_DATA_FILE="parcel.data"
    LOG_START_DELIMETER="--------  $(date)  --------"
    LOG_ENDING_DELIMETER="-------------------- $(date "+%I:%M:%S") -------------------"
    #/////////////////////////////////////////////////////
    # NEW ID AND PARCEL NAME ASSIGNMENT STARTS HERE.
    random_suffix=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
    parcel_id="${random_suffix^^}"
    parcel_name="${parcel_id}.parcel"
    #/////////////////////////////////////////////////////
    # THE PARCEL ID AND NAME ARE NOW AVAILABLE FOR USE.

    #/////////////////////////////////////////////////////
    # MAKE ALL FILES/FOLDERS FOR THE CURRENT PARCEL HERE.
    
    sudo mkdir $parcel_directory

    make-encryption-key
    touch $PARCEL_DATA_FILE
    
    OUTPUT_DIRECTORY="Parcels/"
    
    if [[ ! -d $OUTPUT_DIRECTORY ]]; then
        sudo mkdir "$OUTPUT_DIRECTORY"
    fi

    #/////////////////////////////////////////////////////
    # ITERATING THROUGH TARGETS BEYOND THIS POINT.
    parcel-log $LOG_START_DELIMETER
    write-parcel-data $LOG_START_DELIMETER
    for target in ${targets}; do
        extension=".${target##*.}" # For Files.
        non_extension="${target##*.}/" # For directories
        if [[ $iteration_count -ne $total_targets ]]; then
            #/////////////////////////////////////////////////////
            # BEGINNING OF ITERATION.
            iteration_count=$((iteration_count + 1))
        
            # If the target is a file...
            if [[ -f "$target" ]]; then
                #/////////////////////////////////////////////////////
                # ADDING FILES HERE.
                TARGET_DATA_STRING="$target : $extension : $parcel_id : $parcel_name"
                encrypt-file "$target"
                local _base="$(get-base-file-name $target)"
                target="${_base}.enc" 
                sudo mv "${_base}.enc" "$parcel_directory/"
                
            elif [[ -d "$target" ]]; then
                #/////////////////////////////////////////////////////
                # ADDING FOLDERS HERE.
                TARGET_DATA_STRING="$target : $non_extension : $parcel_id : $parcel_name"
        
                sudo zip -r "./${target}.zip" "$target"
                sudo rm -r "$target"
                sudo mv "${target}.zip" "$parcel_directory/"
            else
                #/////////////////////////////////////////////////////
                # INVALID FILE/FOLDER OPTIONS HERE.
                TARGET_DATA_STRING="$target : [unknown] : $parcel_id : $parcel_name"
            fi
            write-parcel-data $TARGET_DATA_STRING
            parcel-log $TARGET_DATA_STRING
            continue
        fi
    done
    #/////////////////////////////////////////////////////
    # LOOP DONE BEYOND THIS. ALL FILES/FOLDERS ADDED TO parcel/
    parcel-log "$LOG_ENDING_DELIMETER"
    parcel-log ""
    write-parcel-data "$LOG_ENDING_DELIMETER"
    #/////////////////////////////////////////////////////
    # ANY LAST MINUTE FILES THAT SHOULD GO IN parcel/ GOES HERE.
    sudo mv "encryption.key" "$parcel_directory/"
    sudo mv $PARCEL_DATA_FILE "$parcel_directory/"
    #/////////////////////////////////////////////////////
    # ARCHIVING STARTS HERE.
    sudo zip -r "./parcel.zip" "$parcel_directory"
    sudo rm -r "$parcel_directory"
    sudo mv ./parcel.zip ./parcel.parcel

    sudo mv "./parcel.parcel" "./${parcel_name}"
    sudo mv $parcel_name $OUTPUT_DIRECTORY

    # Store the finished fqp for later use.
    PARCEL="$(pwd)/$OUTPUT_DIRECTORY${parcel_name}"
}

parcel test1.txt test1
