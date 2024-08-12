#!/bin/bash

clear

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ASCII Art Header for EFUS
show_header() {
    echo -e "${YELLOW}"
    echo "┏┓┏┓┳┳┏┓  ┳┓┳┳┳┓ ┳┓  ┳┳┓┏┓┳┓┳┳"
    echo "┣ ┣ ┃┃┗┓  ┣┫┃┃┃┃ ┃┃  ┃┃┃┣ ┃┃┃┃"
    echo "┗┛┻ ┗┛┗┛  ┻┛┗┛┻┗┛┻┛  ┛ ┗┗┛┛┗┗┛"
    echo "                              "
    echo -e "${NC}"
}

# List of common packages to check and install if missing
common_packages=(
    build-essential libtool autotools-dev automake pkg-config bsdmainutils curl git python3
)

# List of Win64-specific packages
win64_packages=(
    g++-mingw-w64-x86-64 nsis
)

# Function to check and install missing packages
install_if_missing() {
    local packages=("$@")
    for package in "${packages[@]}"; do
        dpkg -s $package &> /dev/null

        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}Package $package is not installed. Installing...${NC}"
            sudo apt-get install -y $package
        else
            echo -e "${GREEN}Package $package is already installed.${NC}"
        fi
    done
}

# Function to display the menu
show_menu() {
    echo -e "${CYAN}==============================="
    echo -e "   ${YELLOW}Platform Configuration Menu${CYAN}"
    echo -e "===============================${NC}"
    echo -e "${GREEN}1)${NC} Linux32 (${YELLOW}i686-pc-linux-gnu${NC})"
    echo -e "${GREEN}2)${NC} Linux64 (${YELLOW}x86_64-pc-linux-gnu${NC})"
    echo -e "${GREEN}3)${NC} Win64 (${YELLOW}x86_64-w64-mingw32${NC})"
    echo -e "${GREEN}4)${NC} macOS (${YELLOW}x86_64-apple-darwin19${NC})"
    echo -e "${GREEN}5)${NC} Linux ARM 32 bit (${YELLOW}arm-linux-gnueabihf${NC})"
    echo -e "${GREEN}6)${NC} Linux ARM 64 bit (${YELLOW}aarch64-linux-gnu${NC})"
    echo -e "${GREEN}7)${NC} Exit"
    echo -e "${CYAN}===============================${NC}"
}

# Function to configure based on the user's choice
configure_project() {
    local choice=$1
    local prefix=""

    case $choice in
        1) 
            prefix="i686-pc-linux-gnu"
            install_if_missing "${common_packages[@]}"
            ;;
        2) 
            prefix="x86_64-pc-linux-gnu"
            install_if_missing "${common_packages[@]}"
            ;;
        3) 
            prefix="x86_64-w64-mingw32"
            install_if_missing "${common_packages[@]}" "${win64_packages[@]}"
            echo 1 | sudo update-alternatives --config x86_64-w64-mingw32-gcc
            echo 1 | sudo update-alternatives --config x86_64-w64-mingw32-g++
            ;;
        4) 
            prefix="x86_64-apple-darwin19"
            install_if_missing "${common_packages[@]}"
            ;;
        5) 
            prefix="arm-linux-gnueabihf"
            install_if_missing "${common_packages[@]}"
            ;;
        6) 
            prefix="aarch64-linux-gnu"
            install_if_missing "${common_packages[@]}"
            ;;
        7) 
            echo -e "${YELLOW}Exiting...${NC}"; exit 0;;
        *) 
            echo -e "${RED}Invalid option!${NC}"; exit 1;;
    esac

    # Run the build steps
    echo -e "${CYAN}Building dependencies for ${YELLOW}$prefix${CYAN}...${NC}"
    cd depends || { echo -e "${RED}Failed to change directory to 'depends'${NC}"; exit 1; }
    make -j4 || { echo -e "${RED}Failed to build dependencies${NC}"; exit 1; }
    cd .. || { echo -e "${RED}Failed to change back to parent directory${NC}"; exit 1; }

    # Run autogen.sh to generate the necessary scripts
    echo -e "${CYAN}Running autogen.sh...${NC}"
    ./autogen.sh || { echo -e "${RED}Failed to run autogen.sh${NC}"; exit 1; }

    # Configure the project with CONFIG_SITE
    echo -e "${CYAN}Configuring...${NC}"
    CONFIG_SITE=$PWD/depends/$prefix/share/config.site ./configure \
        --disable-bench \
        --disable-tests || { echo -e "${RED}Failed to configure${NC}"; exit 1; }

    # Build the project
    make -j4 || { echo -e "${RED}Failed to build the project${NC}"; exit 1; }
    
    echo -e "${GREEN}Build completed successfully for ${YELLOW}$prefix${GREEN}!${NC}"
}

# Display the header
show_header

# Display the menu and get the user's choice
show_menu
read -p "Enter your choice [1-7]: " choice

# Call the function with the user's choice
configure_project $choice

