#!/bin/bash

function start-parcel() { 

    function fatal() {
        CYAN='\033[0;36m'
        RED='\033[0;31m'
        NC='\033[0m'
        echo -e "$0: ${RED}fatal error:${CYAN} $@ \nPlease provide file name/s and/or folder name/s to create an encrypted ${CYAN}.parcel archive. \nUsage: ${RED}start <file> <file> <folder>${NC}" >&2
        exit 0
    }

    if [[ $# -eq 0 ]]; then
        fatal "No files or folders provided!"
    fi 

    local verbose SOURCE targets_string

    verbose=false
    SOURCE="parcel.sh" #default
    targets_string=""

    # Parse options
    while getopts "v" option; do
        case $option in
        v)
            verbose=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            return 1
            ;;
        esac
    done

    # Shift options
    shift $((OPTIND - 1))

    # Process files/folders
    for arg in "$@"; do

        # Make sure file/folder exists.
        if [ -e "$arg" ]; then
    
            # If file...
            if [ -f "$arg" ]; then
    
                echo "Processing file: $arg"
                targets_string+="$arg "
    
            # If folder...
            elif [ -d "$arg" ]; then
    
                echo "Processing folder: $arg"
                targets_string+="$arg "
    
            fi
            
        else
            echo "File or folder not found: $arg"
        fi
    done
    if [ "$verbose" = true ]; then
        # Add verbose processing logic here
        echo "Verbose output"
        SOURCE="parcel-v.sh"
    fi
    echo "Source: $SOURCE"
    echo "targets: $targets_string"
    bash "$SOURCE" "$targets_string"
}

start-parcel $@
