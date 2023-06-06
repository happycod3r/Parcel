#!/bin/bash 

# TODO: Implement a "forgot pin" system. If the user forgets their pin and security 
# answer as of now, they have no way to recover and will be permanently locked out.
# You can always delete the .answer and .pin files manually which will trigger the 
# pin setup to begin on next startup. That would essentialy do the same thing as 
# parcel --reset.

function sec-gate1() {

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
    new_user="true"

    if [[ ! -d "$CONFIG_DIRECTORY" ]]; then
        mkdir -p "$CONFIG_DIRECTORY"
    fi

    while [[ "$DONE" == "false" ]]; do
        good_pin="false"
        pin_pattern='^[0-9]{4}$' # 4 digits.
        exit_char="q"

    # ------------------- CURRENT USERS ------------------

        if [[ -f "$PIN_FILE" ]]; then

            new_user="false"
            correct_pin="$(cat $PIN_FILE)"
            decoded_pin="$(decode $correct_pin)"

            while [[ "$good_pin" == "false" ]]; do
                clear
                read -p "Enter your pin to continue.
                pin: " pin

                if [[ -z "$pin" ]]; then
                    out "Pin is empty. Enter a valid pin to continue."
                    clear
                    continue
                fi

                if [[ "$pin" == "$exit_char" ]]; then
                    out "Press enter to exit..."
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
                    out "Invalid pin. Must be no less than 4 digits and no letter or characters."
                fi

            done
        fi

        # --------------- NEW USERS ------------------

        while [[ "$good_pin" == "false" ]]; do
            read -p "Set a pin for future use
            Pin or (q) to quit: " pin

            if [[ -z "$pin" ]]; then
                clear
                out "Pin is empty. Enter a valid pin to continue."
                read -p "Press enter to continue..."
                clear
                continue
            fi

            if [[ "$pin" == "$exit_char" ]]; then
                out "Press enter to exit..."
                read -p ""
                clear
                exit 0
            fi

            if [[ $pin =~ $pin_pattern ]]; then
                local encoded_pin="$(encode $pin)"
                echo "$encoded_pin" > $PIN_FILE
                good_pin="true"

            else
                clear
                out "Invalid pin. Must be no less than 4 digits and no letter or characters."
                read -p "Press enter to continue..."
                clear
            fi
        done

        if [[ "$new_user" == "true" ]]; then
        
            # --------------- CTRL QUESTION --------------
            
            local good_question CTRL_QUESTION_FILE
            good_question="false"
            CTRL_QUESTION_FILE="${CONFIG_DIRECTORY}/.q"

            while [[ "$good_question" == "false" ]]; do 
                clear
                out "Now setup a control question to answer to use for operations such as resetting your pin number."

                read -p "Question or (q) to quit: " ctrl_question

                if [[ "$ctrl_question" == "$exit_char" ]]; then
                    out "Press enter to exit..."
                    read -p ""
                    clear
                    exit 0
                fi

                if [[ -z "$ctrl_question" ]]; then
                    out "The control question is empty. Enter a question to continue."
                    clear
                    continue
                fi

                good_question="true"
                echo "$ctrl_question" > $CTRL_QUESTION_FILE

            done

            # --------------- CTRL ANSWER ----------------

            local good_answer CTRL_ANSWER_FILE
            good_answer="false"
            CTRL_ANSWER_FILE="${CONFIG_DIRECTORY}/.answer"

            while [[ "$good_answer" == "false" ]]; do 
            clear
            out "Now write the answer to the ctrl question."

            read -p "Answer or (q) to quit: " ctrl_answer

            if [[ "$ctrl_answer" == "$exit_char" ]]; then
                out "Press enter to exit..."
                read -p ""
                clear
                exit 0
            fi

            if [[ -z "$ctrl_answer" ]]; then
                out "The control answer is empty. Enter an answer to the question you provided to continue."
                clear
                continue
            fi

            good_answer="true"
            DONE="true"
            echo "$(encode $ctrl_answer)" > $CTRL_ANSWER_FILE

            done
        fi

        if [[ $DONE == "true" ]]; then
            break
        fi

    done

}

sec-gate1
