#!/bin/bash

#Check root permission

if [ `whoami` != 'root' ]
  then
    echo "You must be root to do this."
    exit
fi


# Creat SystemD Service

systemd_init () {
    echo "Enter the service name, followed by [ENTER]: "
    read service_name

        while [[ "$service_name" =~ [^a-zA-Z0-9] || -z "$service_name" ]]
            do        
                echo "The input contains special characters."     
                echo "Input only alphanumeric characters."     
                read -p "Enter the service name, followed by [ENTER]: " service_name

            done
                echo "Successful Input"

    touch /etc/systemd/system/"$service_name".service

    echo "Service created"

# PHP Jobs Path

    read -p "Enter the PHP full file path: " php_path

    cat <<EOT >> /etc/systemd/system/$service_name.service
[Unit]
Description=

[Service]
User=root
Type=simple
TimeoutSec=0
PIDFile=/var/run/$service_name.pid
ExecStart=/usr/bin/env php $php_path
KillMode=process

Restart=on-failure
RestartSec=42s

[Install]
WantedBy=default.target
EOT

}

systemd_init

#Starting Service

echo "Enabling the service..."

systemctl enable $service_name"

echo "Starting the service..."

systemctl start $service_name"
