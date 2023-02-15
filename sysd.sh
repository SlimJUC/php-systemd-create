#!/bin/bash

# Check root permission

if [[ $(id -u) -ne 0 ]]; then
  echo "You must be root to run this script."
  exit 1
fi

# Define function to generate systemd service file

generate_service_file() {
  local service_name=$1
  local php_file=$2
  local service_file="/etc/systemd/system/${service_name}.service"

  # Check if service file already exists
  if [[ -f "$service_file" ]]; then
    echo "Service file already exists: $service_file"
    exit 1
  fi

  cat <<EOT >>"$service_file"
[Unit]
Description=

[Service]
User=root
Type=simple
TimeoutSec=0
PIDFile=/var/run/$service_name.pid
ExecStart=/usr/bin/env php "$php_file"
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=default.target
EOT

  echo "Service file created: $service_file"
}

# Prompt user for service name and PHP file path

read -p "Enter the service name, followed by [ENTER]: " service_name_input

while [[ ! "$service_name_input" =~ ^[a-zA-Z0-9]+$ ]]; do
  echo "The input contains special characters."
  echo "Input only alphanumeric characters."
  read -p "Enter the service name, followed by [ENTER]: " service_name_input
done

echo "Successful input"

read -p "Enter the full path to the PHP file: " php_file_input

while [[ ! -f "$php_file_input" ]]; do
  echo "The file does not exist or is not readable."
  read -p "Enter the full path to the PHP file: " php_file_input
done

echo "Successful input"

# Generate systemd service file

generate_service_file "$service_name_input" "$php_file_input"

# Enable and start the service

systemctl enable "$service_name_input.service"
if [[ $? -ne 0 ]]; then
  echo "Failed to enable the service: $service_name_input"
  exit 1
fi

echo "Service enabled: $service_name_input"

systemctl start "$service_name_input.service"
if [[ $? -ne 0 ]]; then
  echo "Failed to start the service: $service_name_input"
  exit 1
fi

echo "Service started: $service_name_input"
