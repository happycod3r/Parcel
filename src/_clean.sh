#!/bin/bash

if [[ -d "Opened-Parcels" ]]; then
    out "This will delete any existing opened parcel archives you may have in the Opened-Parcels folder. Make sure there is nothing you want before continuing!"

    read -p "Do you want to delete all existing opened parcels? (Yes/n)" answer

    if [[ "$answer" == "Yes" ]]; then
        rm -r Opened-Parcels/*
    else
        out "Aborting deletion..."
    fi
    
else
    out "No opened parcels to clean!"
    exit 0
fi
