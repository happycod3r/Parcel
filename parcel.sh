#!/bin/bash

function start-parcel() { 

    source ./src/_init.sh
    clear

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

    if [[ $# -eq 0 ]]; then
        fatal "No files or folders provided!"
    fi 
    
    local extract_parcel delete_parcels import_parcels help_needed uninstall  get_version get_location parcel_archive PARCELS_FOLDER SOURCE targets_string VERSION

    extract_parcel=false
    delete_parcels=false
    import_parcels=false
    help_needed=false
    uninstall=false
    get_version=false
    get_location=false
    clean_opened=false

    parcel_archive="$2"
    PARCELS_FOLDER="Parcels"
    SOURCE="src/_parcel.sh"
    targets_string=""

    #////// * GET OPTIONS * //////
    # [xdvhluic]
    while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
        -x | --extract) # Open a .parcel archive.
            extract_parcel=true
        ;;
        -c | --clean-opened) # Remove any opened parcels. Opened-Parcels/
            clean_opened=true
        ;;
        -d | --delete) # Delete archived parcels from Parcels/.
            delete_parcels=true
        ;;
        -v | --version) # Get the current version.
            get_version=true
        ;;
        -h | --help) # Print options.
            help_needed=true
        ;;
        -l | --get-location) # Get the current location of the .parcel install folder.
            get_location=true
        ;;
        -u | --uninstall) # Remove .parcel from your system.
            uninstall=true
        ;;  
        -i | --import) # Move external .parcel archives into parcels folder, Parcels/.
            import_parcels=true
        ;;
        \?)
            fatal "Invalid option: -$OPTARG"
            return 1
        ;;
    esac; shift; done
    if [[ "$1" == '--' ]]; then shift; fi

    #////// * ADD TARGETS * //////
    for arg in "$@"; do
        # Note this outter clause will probably make it impossible to unarchive any .parcel files that are inside a parcel themselves.
        if [[ ! "$arg" == *.parcel ]]; then
            if [[ -e "$arg" ]]; then # if file/dir exists
                if [[ -f "$arg" ]]; then # if file
                    out "Processing file: $arg"
                    targets_string+="$arg "
                elif [[ -d "$arg" ]]; then # if dir
                    out "Processing folder: $arg"
                    targets_string+="$arg "
                fi
            else # invalid.
                out "File or folder not found: $arg"
                read -p ""
                exit 1
            fi
        else
            out "Target $arg is a .parcel archive."
        fi
    done

    #////// * EXTRACT PARCELS * //////
    if [[ "$extract_parcel" = true ]]; then
        source src/_open.sh
        return 0
    fi

    #////// * DELETE PARCELS * //////
    if [[ "$delete_parcels" = true ]]; then
        source src/_del.sh
        return 0
    fi

    #////// * CLEAN OPENED PARCELS * //////
    if [[ "$clean_opened" = true ]]; then
        source src/_clean.sh
        return 0
    fi

    #////// * IMPORT PARCELS * //////
    if [[ "$import_parcels" = true ]]; then
        source src/_import.sh
        return 0
    fi

    #////// * PRINT HELP * //////
    if [[ "$help_needed" = true ]]; then
        source src/_help.sh
        return 0
    fi

    #////// * UNINSTALL * //////
    if [[ "$uninstall" = true ]]; then
        source src/_uninstall.sh
        return 0
    fi

    #////// * VERSION * //////
    if [[ "$get_version" = true ]]; then
        source src/_version.sh
        return 0
    fi

    #////// * LOCATION * //////
    if [[ "$get_location" = true ]]; then
        source src/_location.sh
        return 0
    fi

    #////// * CREATE PARCEL * //////
    bash "$SOURCE" "$targets_string"
}

start-parcel $@

