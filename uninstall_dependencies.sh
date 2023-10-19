#!/bin/bash

# Remove Python 3.7 and python3.7-venv
sudo apt remove -y python3.7 python3.7-venv

# Remove the deadsnakes PPA
sudo add-apt-repository -r -y ppa:deadsnakes/ppa

# Update package lists after removing the repository
sudo apt update

# Remove software-properties-common
sudo apt remove -y software-properties-common

echo "All installations removed!"
