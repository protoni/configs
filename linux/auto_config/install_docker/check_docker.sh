#!/bin/bash

# Check if Docker is already installed
if [[ $(docker --version | grep "Docker version") == "" ]]; then
    
    echo "Docker installation not found! Installing.."
    
    # Install dependencies
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add Docker repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update

    # Install Docker
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    # Start Docker service
    sudo systemctl start docker
    sudo systemctl enable docker

    # Set permission run for users
    sudo usermod -aG docker $USER

    echo "Docker installed."
else
    echo "Docker is already installed."
fi
