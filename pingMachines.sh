#!/bin/bash

#
# IMPORTS
#

#
# CONSTANTS
#
DEFAULT_DIRECTORY="$HOME/.pingMachines"
HOSTS_FILE="$DEFAULT_DIRECTORY/hosts.conf"
LOGGER="logger -i -t pingMachines"
PING="ping -c 1"
SSH_OPTIONS=" -C echo ACK &> /dev/null"

#
# CODE
#
checkDependencies() {

    [[ $(rpm -q xdialog) ]] || { 
        $LOGGER "package xdialog not installed"
        return 1
    }

}

createDefaultDirectory() {

    if ! [[ -d $DEFAULT_DIRECTORY ]]; then
        mkdir "$DEFAULT_DIRECTORY"
    fi

    return 0
}

parseFile() {
    
    # file not exists: log
    if ! [[ -f $HOSTS_FILE ]]; then
        $LOGGER "host file does not exists, please create one"
        return 1
    fi

    # file exists: get hosts
    source $HOSTS_FILE
}

reachHosts() {
    
    # try to connect to sources
    for host in $HOSTS; do
        
        # host not accessible: check if its answering ping
        ssh $host -o "PasswordAuthentication no" $SSH_OPTIONS || {
            
            # cannot ping: report network issue
            [[ $($PING $host) ]] || {
                Xdialog --title "Ping Machines" --infobox "Cannot ping host $host" 20 1000 4000
                $LOGGER "ping failed on $host"
                continue
            }

            # can ping: report ssh authentication issue
            Xdialog --title "Ping Machines" --infobox "Cannot log using SSH on host $host" 10 80 4000
            $LOGGER "ping failed on $host"
        }
    done
}

main(){
    checkDependencies   

    createDefaultDirectory

    parseFile

    reachHosts
}

main $@
