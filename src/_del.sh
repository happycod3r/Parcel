#!/bin/bash

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

        rm -r "$PARCELS_FOLDER/${parcel}"
    fi
done 
