#!/bin/bash

function _open() {

    SOURCE="src/_extract.sh"

    if [[ -d "Parcels" ]]; then

        selected_parcels=$(ls "$PARCELS_FOLDER" | fzf --multi --cycle --no-sort --preview='echo "$PARCELS_FOLDER/{}"' --preview-window down:10% --layout='reverse-list' --color bg:#222222,preview-bg:#333333)

        for parcel in $selected_parcels; do
            if [[ ! -f "$parcel" ]]; then
                out "Decrypting/extracting parcel: $parcel"
                targets_string="$parcel"
                bash "$SOURCE" "$targets_string"
            fi
        done
    else
        out "No parcels to extract. Create a parcel first."
        read -p "Press Enter to continue."
        clear
    fi
}

_open
