#!/usr/bin/env bash

#########################################
# Alexis Déhu -- 2023-09-18
# MongoDB installation on Ubuntu 22.04
#
# A lancer depuis user supervisor sans
# sudo, mot de passe prompt après
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

updating ()
{
    show_time
    echo -n "Running apt update..."
    sudo apt update &> /dev/null
    check_status
}

installing_dependencies ()
{
    show_time
    echo -n "Installing dependencies..."
    sudo apt-get install -y gnupg curl &> /dev/null
    check_status
}

adding_gpg_key ()
{
    show_time
    echo -n "Adding MongoDB repo GPG key..."
    curl -fsSL https://pgp.mongodb.com/server-6.0.asc | sudo gpg -o /etc/apt/trusted.gpg.d//mongodb-server-6.0.gpg --dearmor &> /dev/null
    check_status
}

adding_mongodb_repo ()
{
    show_time
    echo -n "Adding MongoDB repository..."
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list &> /dev/null
    check_status
}

install_mongodb ()
{
    show_time
    echo -n "Installing MongoDB..."
    sudo apt install -y mongodb-org &> /dev/null
    check_status
}

enabling_service ()
{
    show_time
    echo -n "Enabling & starting MongoDB service..."
    sudo systemctl enable --now mongod &> /dev/null
    hidden_check_status
    sleep 10 
    mongosh --eval "quit" &> /dev/null
    check_status
}

creating_admin_db ()
{
    show_time
    echo -n "Creating "admin" database..."
    echo 'user admin' > script.js
    mongosh < script.js &> /dev/null
    hidden_check_status
    rm -f script.js
    check_status
}

configuring_db ()
{
    show_time
    echo -n "Configuring "root" user..."
    echo "use admin" >> script.js
    echo 'db.createUser({user: "root", pwd: "azerty",roles : [{ role :"userAdminAnyDatabase", db: "admin"},"readWriteAnyDatabase" ]})' >> script.js
    hidden_check_status
    # mongosh --eval "use admin; db.createUser({user: "root", pwd: "azerty",roles : [{ role :"userAdminAnyDatabase", db: "admin"},"readWriteAnyDatabase" ]})" &> /dev/null
    mongosh < script.js &> /dev/null
    hidden_check_status
    rm -f script.js &> /dev/null
    check_status
}

editing_mongodb_conf ()
{
    show_time
    echo -n "Editing MongoDB configuration file..."
    echo "security:" >> sudo tee /etc/mongodb.conf
    hidden_check_status
    echo "authorization: "enabled"" >> sudo tee /etc/mongodb.conf
    check_status
}

restarting_service ()
{
    show_time
    echo -n "Restarting "mongod" service..."
    sudo systemctl restart mongod  &> /dev/null
    check_status
}

installation_is_done ()
{
    echo -e "\n\nInstallation is done\Type this command to connect to the Mongo shell\n\n"
    echo 'mongosh -u "root" -p "azerty" --authenticationDatabase "admin"'
    echo
    exit 0
}

main ()
{
    sudo echo
    clear
    updating
    installing_dependencies
    adding_gpg_key
    adding_mongodb_repo
    updating
    install_mongodb
    enabling_service
    creating_admin_db
    configuring_db
    editing_mongodb_conf
    restarting_service
    installation_is_done
}

main