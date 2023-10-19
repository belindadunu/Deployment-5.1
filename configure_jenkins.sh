#!/bin/bash

# Update package lists and install software-properties-common
sudo apt update
sudo apt install -y software-properties-common

# Add deadsnakes PPA for Python 3.7
sudo add-apt-repository -y ppa:deadsnakes/ppa

# Update package lists again to include packages from the new repository
sudo apt update

# Install Python 3.7 and python3.7-venv
sudo apt install -y python3.7 python3.7-venv

echo "All installations completed!"