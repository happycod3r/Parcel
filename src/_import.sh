#!/bin/bash

PARCELS_FOLDER="Parcels"
if [[ ! -d $PARCELS_FOLDER ]]; then
    mkdir -p "$PARCELS_FOLDER"
fi  
parcels="$@"
for parcel in "$parcels"; do
    parcel_ext=".${parcel##*.}"
    if [[ "$parcel_ext" == ".parcel" ]]; then
        mv "$parcel" "$PARCELS_FOLDER"
    else
        out "$parcel is not a $parcel_ext archive. You can still move it but some operations won't work on it."

        read -p "Continue? (Y/n)" answer

        if [[ "$answer" == "Y" ]]; then
            mv "$parcel" "$PARCELS_FOLDER"
        else
            out "$parcel not imported."
        fi
    fi
done
