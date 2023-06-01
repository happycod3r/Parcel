#!/bin/bash

function start-parcel() { 

    function fatal() {
        CYAN='\033[0;36m'
        RED='\033[0;31m'
        NC='\033[0m'
        echo -e "$0: ${RED}Error:${CYAN} $@" >&2
        exit 0
    }

    function out() {
        CYAN='\033[0;36m'
        PURPLE='\033[0;35m'
        NC='\033[0m'
        echo -e "${CYAN}[parcel] ${PURPLE}$@${NC}"
    }

    out "
                                                      oooo  
                                                       888  
    oo.ooooo.   .oooo.   oooo d8b  .ooooo.   .ooooo.   888  
     888   88b  P  )88b   888  8P d88    Y8 d88   88b  888  
     888   888  .oP-888   888     888       888ooo888  888  
.o.  888   888 d8(  888   888     888   .o8 888    .o  888  
Y8P  888bod8P   Y888  8o d888b     Y8bod8P   Y8bod8P  o888o 
     888                                                    
    o888o 
"

    if [[ $# -eq 0 ]]; then
        fatal "No files or folders provided!"
    fi 
    
    local extract_parcel parcel_archive PARCELS_FOLDER SOURCE targets_string CYAN PURPLE NC VERSION

    PARCEL_VERSION="1.0.0"

    CYAN='\033[0;36m'
    PURPLE='\033[0;35m'
    NC='\033[0m'

    extract_parcel=false
    delete_parcels=false

    parcel_archive="$2"
    PARCELS_FOLDER="Parcels"
    SOURCE="_parcel.sh"
    targets_string=""

    #////// * GET OPTIONS * //////
    while getopts "xdvhl" option; do
        case $option in
        x)
            extract_parcel=true
        ;;
        d)
            delete_parcels=true
        ;;
        v)
            out "Version: $PARCEL_VERSION"
            exit 0
        ;;
        h)
            out "
To create an archive do:
    parcel myfile.txt myfolder
To extract and decrypt an archive/s do:
    parcel -x
To delete an archive/s do:
    parcel -d

for more information check out the README @ https://github.com/happycod3r/parcel
            "
            exit 0
        ;;
        l)
            out "Parcel install Location: $(pwd)"
        ;;
        \?)
            fatal "Invalid option: -$OPTARG"
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

    #////// * EXTRACT PARCELS * //////
    if [[ "$extract_parcel" = true ]]; then
    
        SOURCE="_extract.sh"
        selected_parcels=$(ls "$PARCELS_FOLDER" | fzf --multi --preview 'echo "$PARCELS_FOLDER/{}"')
        
        for parcel in $selected_parcels; do
            if [[ ! -f "$parcel" ]]; then
                out "Decrypting/extracting parcel: $parcel"
                targets_string="$parcel"
                bash "$SOURCE" "$targets_string"
            fi
        done 
        return 0
    fi

    #////// * DELETE PARCELS * //////
    if [[ "$delete_parcels" = true ]]; then
        selected_parcels=$(ls "$PARCELS_FOLDER" | fzf --multi --preview 'echo "$PARCELS_FOLDER/{}"')
        for parcel in $selected_parcels; do
            if [[ ! -f "$parcel" ]]; then
                
                read -p "${CYAN}[parcel]: This will delete the following parcel archives. 
                ${selected_parcels}
                Continue? (yes/no) " answer
                if [[ $answer != "yes" ]]; then
                    out "Deletion aborted."
                    exit 0
                fi

                out "Deleting parcel: $parcel"

                sudo rm -r "$PARCELS_FOLDER/${parcel}"
            fi
        done 
        return 0
    fi

    bash "$SOURCE" "$targets_string"
}

start-parcel $@

