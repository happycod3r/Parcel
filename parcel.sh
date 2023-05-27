#!/bin/bash


function parcel() {
    echo "parcel-v.sh"
    # Data --> parcel.log
    function parcel-log() {
        if [[ ! -f "logs/parcel.log" ]]; then
            touch "parcel.log"
            sudo mv "parcel.log" "logs/"
        fi
        echo "$@" >> "logs/parcel.log"
    }
    # Data --> debug.log
    function debug-log() {
        if [[ ! -f "logs/debug.log" ]]; then
            touch "debug.log"
            sudo mv "debug.log" "logs/"
        fi
        echo "$@" >> logs/debug.log
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

    # Returns my/file/path/file.txt
    print-file-fqp() {
        local file="$1"
        echo "File: $file"
    }

    # Returns: my/target/files/directory
    function get-target-directory() {
        _file="$1"
        _file_fqp="$(readlink -f $_file)"
        _file_path=$(echo "${_file_fqp%/*}")
        echo "$_file_path"
    }

    # Returns: file1.txt ---> file1
    function get-base-file-name() {
        local _file bname
        _file="$1"
        bname=$(echo "$_file" | awk '{gsub(/.*[/]|[.].*/, "", $0)} 1')
        echo "$bname"
    }

    # Creates encryption.key
    function make-encryption-key() {
        bash src/encrypt.sh -g > encryption.key
    }

    # file1.enc ---> file1.enc.gpg
    function gpg-encrypt-file() {
        local _file="$1"
        gpg --symmetric $_file 
        sudo rm "$_file"
    }

    # file1.enc.gpg ---> file1.enc
    function gpg-decrypt-file() {
        local _file="$1"
        # Goes back to .enc to be decrypted by internal encryption.
        bname="$(get-base-file-name $_file)"
        echo "$(gpg --decrypt $_file)" >> "${bname}.enc"
        # probably have to do the following instead so the .enc goes back where it belongs like I did in encrypt-file:
        # echo "$(gpg --decrypt $_file)" >> "(get-target-directory $file)${bname}.enc"
    }

    # file1.txt ---> file1.enc
    function encrypt-file() { #file="$1"
        local _file enc_file bname
        file="$1"
        bname="$(get-base-file-name $file)"
        enc_file="${bname}.enc"
        bash src/encrypt.sh -e -i "$file" -o "$(get-target-directory $file)/${enc_file}" -k "$(cat encryption.key)"
        debug-log "Encrypted: $(get-target-directory $file)$file -> $(get-target-directory $enc_file)$enc_file"
        sudo rm "$file"
    }

    # file1.enc ---> file1.txt
    function decrypt-file() {
        local _file bname
        _file="$1"
        bname="$(get-base-file-name $_file)"
        bash src/encrypt.sh -d -i "$_file" -o "${bname}.txt" -k "$(cat encryption.key)"
        sudo rm "$_file"
    }

    #iterate through files in a folder and its sub folders.
    function process-files() {
        local directory action
        #NOTE: I should probably hard code the parcel/ directory here instead of passing it in as it's never going to be another directory anyway. Plus it's safer that way.
        directory="$1"
        action="$2"
    
        # Iterate through all files and directories in the given directory
        for file in "$directory"/*; do
            if [ -f "$file" ]; then
                # Perform the desired action on the file
                "$action" "$file"
                bname="$(get-base-file-name $file)"
                gpg-encrypt-file "$(get-target-directory $file)/${bname}.enc"
            
            elif [ -d "$file" ]; then
                # Recursively call the function for subdirectories
                process_files "$file" "$action"
            fi
        done
    }

    # ask the user if they want to continue.
    read -p "[parcel]: turn your file/s into a parcell archive. 
    Continue? (yes/no) " answer
    
    if [[ $answer != "yes" ]]; then
        out "Script aborted."
        exit 0
    fi 
    
    local iteration_count targets total_targets current_directory parcel_directory random_suffix parcel_id parcel_name OUTPUT_DIRECTORY PARCEL THIS_DIRECTORY LOG_DIRECTORY CACHE_DIRECTORY extension non_extension PARCEL_DATA_FILE TARGET_DATA_STRING LOG_START_DELIMETER LOG_ENDING_DELIMETER

    THIS_DIRECTORY="$(pwd)"
    iteration_count=0
    targets=$@
    total_targets=$#
    current_directory="$(pwd)"
    parcel_directory="./parcel"
    OUTPUT_DIRECTORY="Parcels/"
    CACHE_DIRECTORY="cache/"
    LOG_DIRECTORY="logs/"
    PARCEL_DATA_FILE="parcel.data"
    LOG_START_DELIMETER="--------  $(date)  --------"
    LOG_ENDING_DELIMETER="-------------------- $(date "+%I:%M:%S") -------------------"

    #/////////////////////////////////////////////////////
    #NOTE: NEW ID AND PARCEL NAME ASSIGNMENT STARTS HERE.
    random_suffix=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
    parcel_id="${random_suffix^^}"
    parcel_name="${parcel_id}.parcel"
    #/////////////////////////////////////////////////////
    #NOTE: THE PARCEL ID AND NAME ARE NOW AVAILABLE FOR USE.

    #/////////////////////////////////////////////////////
    #NOTE: MAKE ALL FILES/FOLDERS FOR THE CURRENT PARCEL HERE.
    sudo mkdir $parcel_directory
    
    make-encryption-key
    touch $PARCEL_DATA_FILE

    if [[ ! -d $OUTPUT_DIRECTORY ]]; then
        sudo mkdir "$OUTPUT_DIRECTORY"
    fi
    if [[ ! -d $LOG_DIRECTORY ]]; then
        sudo mkdir "$LOG_DIRECTORY"
    fi
    if [[ ! -d $CACHE_DIRECTORY ]]; then
        sudo mkdir "$CACHE_DIRECTORY"
    fi
    #/////////////////////////////////////////////////////
    #NOTE: Logs shouldn't be used before this point.
    debug-log $LOG_START_DELIMETER 
    debug-log "Parcel id: $parcel_id"
    debug-log "Parcel name: $parcel_name"
    debug-log "Created encryption.key, $PARCEL_DATA_FILE, $OUTPUT_DIRECTORY"
    #/////////////////////////////////////////////////////
    #NOTE: ITERATING THROUGH TARGETS BEYOND THIS POINT.
    parcel-log $LOG_START_DELIMETER
    write-parcel-data $LOG_START_DELIMETER
    debug-log "[targets] {$targets}"
    for target in ${targets}; do
        extension=".${target##*.}" # For Files.
        non_extension="${target##*.}/" # For directories

        if [[ $iteration_count -ne $total_targets ]]; then
            #/////////////////////////////////////////////////////
            #NOTE: BEGINNING OF ITERATION.
            debug-log "-----------------------------"
            debug-log "Iteration [$iteration_count] beginning on [$target]"
            iteration_count=$((iteration_count + 1))
        
            # If the target is a file...
            if [[ -f "$target" ]]; then
                #/////////////////////////////////////////////////////
                #NOTE: ADDING FILES HERE.
                TARGET_DATA_STRING="$target : $extension : $parcel_id : $parcel_name"
                encrypt-file "$target"
                local _base="$(get-base-file-name $target)"
                #NOTE: sudo rm $target Not sure if I need this, but thought that the original file may still be left behind after encryption... 
                target="${_base}.enc"

                gpg-encrypt-file "$target"
                sudo rm $target
                target="${target}.gpg"

                sudo mv "$target" "$parcel_directory/"
                debug-log "${_base}$extension encrypted: ${_base}$extension ---> $target"
                debug-log "$target ---> $parcel_directory/"
            elif [[ -d "$target" ]]; then
                #/////////////////////////////////////////////////////
                #NOTE: ADDING FOLDERS HERE.
                TARGET_DATA_STRING="$target : $non_extension : $parcel_id : $parcel_name"

                process-files "$target" "encrypt-file"

                sudo zip -r "./${target}.zip" "$target"
                debug-log "$target ---> ${target}.zip"
                sudo rm -r "$target"
    
                sudo mv "${target}.zip" "$parcel_directory/"
                debug-log "${target}.zip ---> $parcel_directory/"
            else
                #/////////////////////////////////////////////////////
                #NOTE: INVALID FILE/FOLDER OPTIONS HERE.
            
                TARGET_DATA_STRING="$target : [unknown] : $parcel_id : $parcel_name"
            fi

            write-parcel-data $TARGET_DATA_STRING
            parcel-log $TARGET_DATA_STRING
            debug-log $TARGET_DATA_STRING
            debug-log "-----------------------------"
            continue
        fi
    done
    #/////////////////////////////////////////////////////
    #NOTE: LOOP DONE BEYOND THIS. ALL FILES/FOLDERS ADDED TO parcel/
    parcel-log "$LOG_ENDING_DELIMETER"
    parcel-log ""
    write-parcel-data "$LOG_ENDING_DELIMETER"
    debug-log "logs ended." 
    #/////////////////////////////////////////////////////
    #NOTE: ANY LAST MINUTE FILES THAT SHOULD GO IN parcel/ GOES HERE.
    
    sudo mv "encryption.key" "$parcel_directory/"
    sudo mv $PARCEL_DATA_FILE "$parcel_directory/"
    debug-log "encryption.key, $PARCEL_DATA_FILE ---> $parcel_directory"
    #/////////////////////////////////////////////////////
    #NOTE: ARCHIVING STARTS HERE.
    sudo zip -r "./parcel.zip" "$parcel_directory"
    sudo rm -r "$parcel_directory"

    sudo mv ./parcel.zip ./parcel.parcel
    debug-log "parcel.zip ---> parcel.parcel"
    sudo mv "./parcel.parcel" "./${parcel_name}"
    debug-log "parcel.parcel ---> ${parcel_name}"
    sudo mv $parcel_name $OUTPUT_DIRECTORY

    #NOTE: Store the finished fqp for later use.
    PARCEL="$(pwd)/$OUTPUT_DIRECTORY${parcel_name}"
    debug-log "$LOG_ENDING_DELIMETER"
    debug-log ""
}

parcel $@
