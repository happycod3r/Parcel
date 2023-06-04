#!/bin/bash

function _uninstall() {
    read -p "This will remove .parcel from your system. You can always redownload it, but there is no going back once you remove this instance of it. I would suggest you manually remove any .parcel packages you may currently have that you would like to keep as this action will delete the Parcels folder and everything in it.
    To unencrypt/unarchive any saved .parcel archives reinstall .parcel and run:
        parcel <location to your .parcel> 
    This will move your .parcel to the Parcels folder for so that you can decrypt/unarchive them when you want.
    Continue? [n/Yes]" answer
    if [[ -z "$answer" ]]; then
        out "No answer provided. Canceling uninstallation of parcel"
        exit 0
    fi

    if [[ "$answer" == "Yes" ]]; then
        read -p "Are you sure you? (y/n)" answer
        if [[ "$answer" == "y" ]]; then
            rm -r "$(pwd)"
        else
            exit 0
        fi
    fi
}

_uninstall
