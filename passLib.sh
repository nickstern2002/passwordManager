# Library File for manager.sh

passwordBook=./passBook.txt
export passwordBook

check_master(){
    input="$1"
    master=`egrep ':[A-Za-z0-9]+:' masterPass.txt | cut -d ":" -f2`
    for i in 3 2 1; do
        if [ "$input" != "$master" ]; then
            if [ "$i" -eq "1" ]; then
                return 1
            fi
            echo "Incorrect password. `expr $i - 1` attempts remaing"
            read input
        else
            return 0
        fi
    done
}

confirmation(){
    echo -n "Respod with yes(y) or no(n): "
    read response
    case $response in
        "y")
            return 0
            ;;
        "n")
            return 1
            ;;
        *)
            echo "Invalid Response. Try Again"
            confirmation
            ;;
    esac
}

displayServices(){
    serviceList=`cat passBook.txt`
    n=1
    while read -r line; do
        echo "${n}: `echo "$line" | cut -d ":" -f1`"
        (( n++ ))
    done <<< "$serviceList" 
}

add_pass(){
    echo "You will be prompted for two pieces of information. The service and the associated password"
    sleep 1
    echo -n "What service is this password for? "
    read service
    if grep -q "$service" passBook.txt; then
        echo "Service already has an input. Would you like to edit it?"
        read response
        case "$response" in
            "y")
                edit_pass
                return 0
                ;;
            "n")
                return 0
                ;;
            *)
                return 2
                ;;
        esac
    fi
    echo -n "What is your password? "
    read -s password
    echo "$service:$password" >> passBook.txt
    echo
    echo "Password successfully added"
}

search_pass(){
    echo -n "Please provide the master password to continue: "
    read -s inp_master
    echo
    if ! check_master "$inp_master" ; then
        echo "Verification failed"
        exit 0
    fi
    displayServices
    echo -en "What service would you like to search for? "
    read service
    password=`grep "$service" passBook.txt | cut -d ":" -f2`
    if [ -z "$password" ]; then
        echo "No password for $service found"
        return 0
    fi
    echo "Service: [${service}]"
    echo "Password: [${password}]"
}

delete_pass(){
    echo -n "Please provide the master password to continue: "
    read -s inp_master
    echo 
    if ! check_master "$inp_master" ; then
        echo "Verification failed"
        exit 0
    fi
    echo -en "What service would you like to delete? "
    read service
    if [ -z "$service" ]; then
        echo "No service given"
        return 1
    fi
    lineToDel=`grep "$service" passBook.txt`
    if [ -z "$lineToDel" ]; then
        echo "Service not found"
        return 1
    fi
    echo "Service: [`echo "$lineToDel" | cut -d ":" -f1`]"
    echo "Password: [`echo "$lineToDel" | cut -d ":" -f2`]"
    echo -en "Is this the correct Service? "
    if ! confirmation ; then
        echo "Returning to menu"
        return 0
    fi
    sed -i "/$lineToDel/d" "passBook.txt"
    echo "$service successfully deleted"
}

edit_pass(){
    echo -n "Please provide the master password to continue: "
    read -s inp_master
    echo
    if ! check_master "$inp_master" ; then
        echo "Verification failed"
        exit 0
    fi
    displayServices 
    echo -en "What service would you like to edit? "
    read service
    if [ -z "$service" ]; then
        echo "No service given"
        return 1
    fi

    textEdit=`grep "$service" passBook.txt`

    if [ -z "$textEdit" ]; then
        echo "Service not found"
        return 2
    fi

    echo -n "Provide your new password for `echo "$textEdit" | cut -d ":" -f1`: "
    read newPass
    sed -i "/$textEdit/d" passBook.txt
    echo "`echo "$textEdit" | cut -d ":" -f1`:$newPass" >> passBook.txt
}
