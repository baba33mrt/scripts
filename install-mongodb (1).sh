#!/usr/bin/env bash

#########################################
# MARTIN Baptiste -- 2024-11-12
# freeRadius installation on Ubuntu 22.04
#
# A lancer depuis user supervisor sans
# sudo, mot de passe prompt apr\u00e8s
#########################################

show_time ()
{
    echo -n "$(date +%r)-- "
}

check_status ()
{
    if [ $? -eq 0 ]; then
        echo "done"
    else
        cat /dev/null
        echo -e "failed\n\nAn error occured\nI made the program quit\n\n"
        exit 1
    fi
}

hidden_check_status ()
{
    if [ $? -ne 0 ]; then
        cat /dev/null
        echo -e "failed\n\nAn error occured during the installation\nI made the program quit\n\n"
        exit 1
    fi
}

add_proxy()
{
    show_time
    echo -n "Adding proxy..."
    sudo echo "Acquire {
  HTTP::proxy "http://cache.univ-pau.fr:3128";
  HTTPS::proxy "http://cache.univ-pau.fr:3128";
}" > /etc/apt/apt.conf.d/proxy
}

updating ()
{
    show_time
    echo -n "Running apt update..."
    sudo apt update &> /dev/null
    check_status
}


install_freeradius ()
{
    show_time
    echo -n "Installing FreeRadius..."
    sudo apt install -y freeradius &> /dev/null
    check_status
}



installation_is_done ()
{
    echo -e "\n\nInstallation is done\n\n"
    echo "Folder is /etc/freeradius/3.0/"
    installed=("yes")
	select item in "${installed[@]}" Quit
	    do
	        
                case $REPLY in
		    1) sudo cd /etc/freeradius/3.0/;;

                    $((${#installed[@]}+1))) echo "We're done!"; break;;
        *) echo "Ooops - unknown choice $REPLY";;
    esac
done

    echo
    exit 0
}

install ()
{
    sudo echo
    clear
    add_proxy
    updating
    install_freeradius
    installation_is_done
}



	
items=("Install" "Clear config" "Item 3")
select item in "${items[@]}" Quit
do
    case $REPLY in
        1) install;;
        2) echo "Selected item #$REPLY which means $item";;
        3) echo "Selected item #$REPLY which means $item";;
        
        $((${#items[@]}+1))) echo "We're done!"; break;;
        *) echo "Ooops - unknown choice $REPLY";;
    esac
done
