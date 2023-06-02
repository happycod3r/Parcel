#!/bin/bash 

function main() {
    
    DONE="false"
    CONFIG_DIRECTORY=".config"
    PIN_FILE=".config/.pin"

    if [[ ! -d "$CONFIG_DIRECTORY" ]]; then
        mkdir -p "$CONFIG_DIRECTORY"
    fi

    while [[ "$DONE" == "false" ]]; do

        good_pin="false"
        pin_pattern='^[0-9]{4}$'
        exit_char="q"

        if [[ -f "$PIN_FILE" ]]; then

            correct_pin="$(cat $PIN_FILE)"
            
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
                
                    if [[ "$pin" == "$correct_pin" ]]; then
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
                echo "$pin" > $PIN_FILE
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
