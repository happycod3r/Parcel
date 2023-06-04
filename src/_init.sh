#!/bin/bash 

function main() {

    encode() {
        if [[ $# -eq 0 ]]; then
            cat | base64
        else
            printf '%s' $1 | base64
        fi
    }

    decode() {
        if [[ $# -eq 0 ]]; then
            cat | base64 --decode
        else
            printf '%s' $1 | base64 --decode
        fi
    }
    
    fpath=('$(pwd)' $fpath)

    DONE="false"
    CONFIG_DIRECTORY="${HOME}/.config/parcel"
    PIN_FILE="${CONFIG_DIRECTORY}/.pin"
    USER_FILE="${CONFIG_DIRECTORY}/.user"

    if [[ ! -d "$CONFIG_DIRECTORY" ]]; then
        mkdir -p "$CONFIG_DIRECTORY"
    fi

    # ------------------- CURRENT USERS ------------------

    while [[ "$DONE" == "false" ]]; do

        good_pin="false"
        pin_pattern='^[0-9]{4}$' # 4 digits.
        user_pattern='^[0-9a-zA-Z]{8}$' # 8 characters, numbers & letters only
        exit_char="q"

        if [[ -f "$PIN_FILE" ]]; then
        
            correct_pin="$(cat $PIN_FILE)"
            decoded_pin="$(decode $correct_pin)"

            while [[ "$good_pin" == "false" ]]; do

                read -p "Enter your pin to continue.
                pin: " pin

                if [[ -z "$pin" ]]; then
                    echo "Pin is empty. Enter a valid pin to continue."
                    clear
                    continue
                fi

                if [[ "$pin" == "$exit_char" ]]; then
                    echo "Press enter to exit..."
                    read -p ""
                    clear
                    exit 0
                fi

                if [[ $pin =~ $pin_pattern ]]; then
                
                    if [[ "$pin" == "$decoded_pin" ]]; then
                        good_pin="true"
                        DONE="true"
                        break
                    else
                        continue
                    fi

                else
                    clear
                    echo "Invalid pin. Must be no less than 4 digits and no letter or characters."
                fi

            done
        fi

        # ------------------- NEW USERS ------------------

        while [[ "$good_pin" == "false" ]]; do
            read -p "Set a pin for future use:
        pin: " pin

            if [[ -z "$pin" ]]; then
                echo "Pin is empty. Enter a valid pin to continue."
                clear
                continue
            fi

            if [[ "$pin" == "$exit_char" ]]; then
                echo "Press enter to exit..."
                read -p ""
                clear
                exit 0
            fi

            if [[ $pin =~ $pin_pattern ]]; then
                local encoded_pin="$(encode $pin)"
                echo "$encoded_pin" > $PIN_FILE
                good_pin="true"
                DONE="true"
            else
                echo "Invalid pin. Must be no less than 4 digits and no letter or characters."
            fi

        done

        if [[ $DONE == "true" ]]; then
            break
        fi

    done

}

main
