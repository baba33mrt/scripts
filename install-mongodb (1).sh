#!/usr/bin/env bash

#########################################
# MARTIN Baptiste -- 2024-11-12
# FreeRadius installation and configuration for TP on Ubuntu 22.04
# Run as a user supervisor without sudo, password prompt after
#########################################

# Function to show the current time with a message
show_time () {
    echo -n "$(date +%r)-- "
}

# Function to check the status of the last command and exit if it failed
check_status () {
    if [ $? -eq 0 ]; then
        echo "done"
    else
        echo -e "failed\n\nAn error occurred\nExiting the program\n\n"
        exit 1
    fi
}

# Step 1: Adding proxy configuration
add_proxy() {
    show_time
    echo -n "Adding proxy..."
    sudo tee /etc/apt/apt.conf.d/proxy > /dev/null <<EOF
Acquire {
  HTTP::proxy "http://cache.univ-pau.fr:3128";
  HTTPS::proxy "http://cache.univ-pau.fr:3128";
}
EOF
    check_status
}

# Step 2: Update package list and install FreeRADIUS
update_packages () {
    show_time
    echo -n "Running apt update..."
    sudo apt update &> /dev/null
    check_status
}

install_freeradius () {
    show_time
    echo -n "Installing FreeRadius..."
    sudo apt install -y freeradius &> /dev/null
    check_status
}

# Step 3: Configure FreeRADIUS files
configure_freeradius () {
    show_time
    echo -n "Configuring FreeRadius..."
    
    # Backup and clean radiusd.conf file
    sudo cp /etc/freeradius/3.0/radiusd.conf /etc/freeradius/3.0/radiusd.conf.bak
    sudo grep -v "^\s*#" /etc/freeradius/3.0/radiusd.conf | grep -v "^$" | sudo tee /etc/freeradius/3.0/radiusd.conf.clean > /dev/null
    
    # Backup and clean default file
    sudo cp /etc/freeradius/3.0/sites-available/default /etc/freeradius/3.0/sites-available/default.orig
    sudo grep -v "^\s*#" /etc/freeradius/3.0/sites-available/default | grep -v "^$" | sudo tee /etc/freeradius/3.0/sites-available/default.clean > /dev/null
    
    # Add users to FreeRADIUS users file
    sudo tee -a /etc/freeradius/3.0/users > /dev/null <<EOF
anthony Cleartext-Password := "tony"
    Tunnel-Private-Group-Id = 3

jjb Cleartext-Password := "sesame"
    Tunnel-Private-Group-Id = 4
EOF
    check_status
}

# Step 4: Restart FreeRADIUS in debug mode to check configuration
restart_freeradius_debug () {
    show_time
    echo -n "Restarting FreeRadius in debug mode..."
    sudo /usr/sbin/freeradius -X &
    check_status
}

# Step 5: Configure NAS (router)
configure_nas () {
    show_time
    echo -n "Configuring NAS (router)..."
    # Commands to configure Cisco router as NAS (this is pseudocode, execute on Cisco CLI)
    echo "Configuring AAA authentication on router"
    echo "aaa new-model"
    echo "aaa authentication login default group radius"
    echo "radius-server host <IP_SERVER> auth-port 1812 acct-port 1813 key <SECRET_KEY>"
    echo "line vty 0 4"
    echo "login authentication default"
    echo "exit"
    check_status
}

# Function to indicate installation completion
installation_done () {
    echo -e "\n\nInstallation and Configuration is complete.\n"
    echo "FreeRadius is installed and configured at /etc/freeradius/3.0/"
    exit 0
}

# Main install function to run all steps
install () {
    clear
    add_proxy
    update_packages
    install_freeradius
    configure_freeradius
    restart_freeradius_debug
    configure_nas
    installation_done
}

# Main script execution starts here
items=("Install" "Clear config" "Quit")
select item in "${items[@]}"
do
    case $REPLY in
        1) install;;
        2) echo "Selected item #$REPLY which means $item";;
        3) echo "Exiting..."; break;;
        *) echo "Oops - unknown choice $REPLY";;
    esac
done
