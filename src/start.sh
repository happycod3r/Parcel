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

my_function() {
    verbose=false

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
        if [ -e "$arg" ]; then
        if [ -f "$arg" ]; then
            echo "Processing file: $arg"
        elif [ -d "$arg" ]; then
            echo "Processing folder: $arg"
        fi
        if [ "$verbose" = true ]; then
            # Add verbose processing logic here
            echo "Verbose output for $arg"
        fi
        else
        echo "File or folder not found: $arg"
        fi
    done
}
