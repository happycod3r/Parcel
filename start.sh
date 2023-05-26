#!/bin/bash

function start() {

    is_file_empty() {
        local file="$1"
        if [ -s "$file" ]; then
            echo "The file $file is not empty."
        else
            echo "The file $file is empty."
        fi
    }   

    if [[ ! -f "state.data" ]]; then
        touch state.data
        echo "setup" >> state.data
    fi

    
}

start-parcel() { 
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
            
            if [ "$verbose" = true ]; then
            # Add verbose processing logic here
                echo "Verbose output"
                SOURCE="parcel-dev.sh"
            fi
        else
            echo "File or folder not found: $arg"
        fi
    done
    echo "Source: $SOURCE"
    echo "targets: $targets_string"
    bash $SOURCE $targets_string
}

start-parcel $@
