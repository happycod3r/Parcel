#!/bin/bash

function _reset-pin() {

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

    local good_answer DONE CONFIG_DIRECTORY

    DONE="false"
    CONFIG_DIRECTORY="${HOME}/.config/parcel"
    good_answer="false"
    correct_answer="$(cat $CONFIG_DIRECTORY/.answer | decode)"
    exit_char="q"

    while [[ "$good_answer" == "false" ]]; do
        clear 
        echo "Enter the answer to your security question to continue!"

        echo "$(cat $CONFIG_DIRECTORY/.q)"

        read -p "Answer? " answer

        if [[ "$answer" == "$exit_char" ]]; then
            echo "Press enter to exit..."
            read -p ""
            clear
            exit 0
        fi

        if [[ -z "$answer" ]]; then
            clear
            echo "You must answer the question in order to reset your pin"
            read -p "Press enter to continue..."
            clear
            continue
        fi

        if [[ "$answer" == "$correct_answer" ]]; then
            clear
            
            local good_pin PIN_FILE

            PIN_FILE="${CONFIG_DIRECTORY}/.pin"
            good_pin="false"
            pin_pattern='^[0-9]{4}$' # 4 digits.

            while [[ "$good_pin" == "false" ]]; do

                echo "Enter a new 4 digit pin to continue."
                read -p "Pin or (q) to quit: " pin 
                
                if [[ "$pin" == "$exit_char" ]]; then
                    echo "Press enter to exit..."
                    read -p ""
                    clear
                    exit 0
                fi

                if [[ -z "$pin" ]]; then
                    clear
                    echo "You must enter a new pin in order to reset your current one."
                    read -p "Press enter to continue..."
                    clear
                    continue
                fi

                if [[ $pin =~ $pin_pattern ]]; then
                    local encoded_pin="$(encode $pin)"
                    echo "$encoded_pin" > $PIN_FILE
                    clear
                    echo "Pin was reset!"
                    read -p "Press enter to continue..."
                    clear
                    good_pin="true"
                    DONE="true"
                    break
                fi

            done
        fi

        if [[ $DONE == "true" ]]; then
            break
        fi

    done

}

_reset-pin
