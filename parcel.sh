#!/bin/bash

function start-parcel() { 

    function fatal() {
        CYAN='\033[0;36m'
        RED='\033[0;31m'
        NC='\033[0m'
        echo -e "$0: ${RED}fatal error:${CYAN} $@ \nPlease provide file name/s and/or folder name/s to create an encrypted.parcel archive. \nFor usage info check out the man page at: ${RED}https://github.com/happycod3r/Parcel${NC}" >&2
        exit 0
    }

    function out() {
        CYAN='\033[0;36m'
        PURPLE='\033[0;35m'
        NC='\033[0m'
        echo -e "${CYAN}[parcel] ${PURPLE}$@${NC}"
    }

    if [[ $# -eq 0 ]]; then
        fatal "No files or folders provided!"
    fi 
    
    local extract_parcel parcel_archive PARCELS_FOLDER SOURCE targets_string CYAN PURPLE NC

    CYAN='\033[0;36m'
    PURPLE='\033[0;35m'
    NC='\033[0m'

    extract_parcel=false
    parcel_archive="$2"
    PARCELS_FOLDER="Parcels"
    SOURCE="_parcel.sh"
    targets_string=""

    #////// * GET OPTIONS * //////
    while getopts "x" option; do
        case $option in
        x)
            extract_parcel=true
        ;;
        \?)
            echo -e "${CYAN}[parcel] ${PURPLE}Invalid option:${NC} -$OPTARG" >&2
            return 1
        ;;
        esac
    done
    
    shift $((OPTIND - 1))

    #////// * ADD TARGETS * //////
    for arg in "$@"; do
        # Note this outter clause will probably make it impossible to unarchive any .parcel files that are inside a parcel themselves.
        if [[ ! "$arg" == *.parcel ]]; then
            if [ -e "$arg" ]; then # if file/dir exists
                if [ -f "$arg" ]; then # if file
                    out "Processing file: $arg"
                    targets_string+="$arg "
                elif [ -d "$arg" ]; then # if dir
                    out "Processing folder: $arg"
                    targets_string+="$arg "
                fi
            else # invalid.
                out "File or folder not found: $arg"
            fi
        fi
    done

    #////// * EXTRACT TARGETS * //////
    if [ "$extract_parcel" = true ]; then
        out "hello"
        targets_string="$parcel_archive"
        SOURCE="_extract.sh"
        selected_parcels=$(ls "$PARCELS_FOLDER" | fzf --multi --preview 'echo "$PARCELS_FOLDER/{}"')
        for parcel in $selected_parcels; do
            if [[ ! -f "$parcel" ]]; then
                out "Parcel: ${parcel}"
                out "Reading file: $PARCELS_FOLDER/$parcel"
                targets_string="$parcel"

                out "source: $SOURCE"
                out "target: $targets_string"
                bash "$SOURCE" "$targets_string"
            fi
        done 
        return 0
    fi

    bash "$SOURCE" "$targets_string"
}

start-parcel $@

