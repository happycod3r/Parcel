#!/bin/bash

function doc-out() {
    echo "- ### $@" >> CONTROL_FLOW.md
}

function parcel() {

    doc-out "parcel()"

    function fatal() {
        doc-out "fatal()"

        CYAN='\033[0;36m'
        RED='\033[0;31m'
        NC='\033[0m'
        echo -e "${CYAN}[parcel]$0: ${RED}fatal error:${CYAN} $@ \nPlease provide file name/s and/or folder name/s to create an encrypted ${CYAN}.parcel archive. \nUsage: ${RED}start <file> <file> <folder>${NC}" >&2
        exit 0
    }

    function parcel-log() {
        doc-out "parcel-log()" 
        if [[ ! -f "logs/parcel.log" ]]; then
            touch "parcel.log"
            sudo mv "parcel.log" "logs/"
        fi
        echo "$@" >> "logs/parcel.log"
    }
    
    function debug-log() {
        #doc-out "debug-log()" 
        if [[ ! -f "logs/debug.log" ]]; then
            touch "debug.log"
            sudo mv "debug.log" "logs/"
        fi
        echo "$@" >> logs/debug.log
    }

    function out() {
        doc-out "out()" 
        CYAN='\033[0;36m'
        PURPLE='\033[0;35m'
        NC='\033[0m'
        echo -e "${CYAN}[parcel] ${PURPLE}$@${NC}"
        sleep 1
    }

    function error-out {
        doc-out "error-out()" 
        echo -e "$@"
        sleep 1
    }
    
    function write-parcel-data() {
        doc-out "write-parcel-data()" 
        if [[ ! -f "parcel.data" ]]; then
            touch parcel.data
        fi
        echo "$@" >> parcel.data
    }

    function get-target-directory() {
        doc-out "get-target-directory()" 
        local _file _file_fqp _file_path
        _file="$1"
        _file_fqp="$(readlink -f $_file)"
        _file_path=$(echo "${_file_fqp%/*}")
        echo "$_file_path"
    }

    function get-base-file-name() {
        doc-out "get-base-file-name()" 
        local _file bname
        _file="$1"
        bname=$(echo "$_file" | awk '{gsub(/.*[/]|[.].*/, "", $0)} 1')
        echo "$bname"
    }

    function gpg-encrypt-target() {
        doc-out "gpg-encrypt-target()" 
        local _file
        _file="$1"
        gpg --symmetric $_file 
        sudo rm "$_file"
    }
    
    function make-encryption-key() {
        doc-out "make-encryption-key()" 
        bash src/encrypt.sh -g > encryption.key
        PARCEL_KEY="$(cat -u encryption.key)"
    }

    function encrypt-target() { #file="$1"
        doc-out "encrypt-target()" 
        local _file enc_file bname
        file="$1"
        bname="$(get-base-file-name $file)"
        enc_file="${bname}.enc"
        bash src/encrypt.sh -e -i "$file" -o "$(get-target-directory $file)/${enc_file}" -k "$(cat encryption.key)"
        debug-log "Encrypted: $(get-target-directory $file)$file -> $(get-target-directory $enc_file)$enc_file"
        sudo rm "$file"
    }

    function arc-target() {
        doc-out "arc-target()" 
        local bname target file1 file2
        target="$1"
        bname="$(get-base-file-name $target)"
        ./src/bin/arc ao $bname $target
        sudo rm "$target"

        file1="${bname}.arc"
        file2="$(get-target-directory $target)/${bname}.arc"

        if [[ "$(realpath $file1)" != "$(realpath $file2)" ]]; then
            mv "${bname}.arc" "$(get-target-directory $target)/${bname}.arc"
            return 0
        fi        
    }

    function zip-target() {
        doc-out "zip-target()"
        local target
        target="$1"
        sudo zip -r "./${target}.zip" "$target"
    }

    function process-files() {
        doc-out "process-files()"
        local directory action extension non_extension TARGET_DATA_STRING
        directory="$1"
        action="$2"
        extension=".${target##*.}" # For Files.
        non_extension="${target##*.}/" # For directories
        for file in "$directory"/*; do
            if [ -f "$file" ]; then
                TARGET_DATA_STRING="$file : $extension : $parcel_id : $parcel_name"
                "$action" "$file"
            elif [ -d "$file" ]; then
                # Recursively call process-files for any sub-directories.
                TARGET_DATA_STRING="$file : $non_extension : $parcel_id : $parcel_name"
                process-files "$file" "$action"
            fi
            parcel-log $TARGET_DATA_STRING
        done
    }

    read -p "[parcel]: turn your file/s into a parcell archive. 
    Continue? (yes/no) " answer
    
    if [[ $answer != "yes" ]]; then
        out "Script aborted."
        exit 0
    fi
    
    local iteration_count targets total_targets current_directory parcel_directory random_suffix parcel_id parcel_name OUTPUT_DIRECTORY PARCEL THIS_DIRECTORY LOG_DIRECTORY CACHE_DIRECTORY extension non_extension PARCEL_DATA_FILE TARGET_DATA_STRING LOG_START_DELIMETER LOG_ENDING_DELIMETER PARCEL_KEY

    THIS_DIRECTORY="$(pwd)"
    iteration_count=0
    targets=$@
    total_targets=$#
    current_directory="$(pwd)"
    OUTPUT_DIRECTORY="Parcels/"
    CACHE_DIRECTORY="cache/"
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
    debug-log "$PARCEL_KEY"

    #/////////////////////////////////////////////////////
    #NOTE: ITERATING THROUGH TARGETS BEYOND THIS POINT.
    
    parcel-log $LOG_START_DELIMETER
    write-parcel-data $LOG_START_DELIMETER
    write-parcel-data "key:$PARCEL_KEY"
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
            
            if [[ -f "$target" ]]; then

                #/////////////////////////////////////////////////////
                #NOTE: ADDING FILES HERE.
            
                TARGET_DATA_STRING="$target : $extension : $parcel_id : $parcel_name"

                encrypt-target "$target"
                
                _base="$(get-base-file-name $target)"
                target="${_base}.enc"
                
                arc-target "$target"

                _base="$(get-base-file-name $target)"
                target="${_base}.arc"

                sudo mv "$target" "$parcel_directory/"
            
                debug-log "${_base}$extension encrypted: ${_base}$extension ---> $target"
                debug-log "$target ---> $parcel_directory/"

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
                debug-log "$target ---> ${target}.zip"
                sudo rm -r "$target"
            
                sudo mv "${target}.zip" "$parcel_directory/"
                debug-log "${target}.zip ---> $parcel_directory/"

            else

                #/////////////////////////////////////////////////////
                #NOTE: INVALID FILE/FOLDER OPTIONS HERE.

                TARGET_DATA_STRING="$target : [unknown] : $parcel_id : $parcel_name"
                error-out "\n$TARGET_DATA_STRING\n"            
            fi

            write-parcel-data $TARGET_DATA_STRING
            parcel-log $TARGET_DATA_STRING
            parcel-log "key:${PARCEL_KEY}"
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

    gpg-encrypt-target "./parcel.zip" #  RVVZI3JUAV.zip.gpg ---> RVVZI3JUAV.parcel 

    sudo mv ./parcel.zip.gpg ./parcel.gpg.parcel
    debug-log "parcel.zip.gpg ---> parcel.parcel"
    sudo mv "./parcel.gpg.parcel" "./${parcel_name}"
    debug-log "parcel.parcel ---> ${parcel_name}"
    sudo mv $parcel_name $OUTPUT_DIRECTORY

    PARCEL="$(pwd)/$OUTPUT_DIRECTORY${parcel_name}"
    debug-log "$LOG_ENDING_DELIMETER"
    debug-log ""
}

parcel $@
