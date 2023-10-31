#!/bin/bash

. ./passLib.sh

show_menu(){
    while : ; do
        echo "Make a choice from the following menu"
        echo "1. Search"
        echo "2. Add"
        echo "3. Delete"
        echo "4. Edit"
        echo "5. Quit"
        read input

        case $input in
            1)
                search_pass
                ;;
            2)
                add_pass
                ;;
            3)
                delete_pass
                ;;
            4)
                edit_pass
                ;;
            5)
                echo "Goodbye"
                exit 0
                ;;
            *)
                echo "Invalid Input! Please Try Again"
                ;;
        esac  
    done

}


###
# Main
###

echo "Hello. Welcome to the password manager"

if [ -e masterPass.txt ]; then
    if ! egrep -q :[a-z0-9A-Z]+: masterPass.txt; then
        echo -n "Please provide a master password in order to continue: "
        read -s master
        echo ":$master:" > masterPass.txt
        echo
    fi
else
     echo -n "Please provide a master password in order to continue: "
     read -s master
     echo ":$master:" > masterPass.txt
     echo
fi

show_menu
