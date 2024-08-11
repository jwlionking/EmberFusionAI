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

# List of packages to check and install if missing
packages=(
    "make"
    "automake"
    "curl"
    "g++-multilib"
    "libtool"
    "binutils-gold"
    "bsdmainutils"
    "pkg-config"
    "python3"
    "patch"
    "bison"
    "build-essential"
    "libtool"
    "autotools-dev"
    "automake"
    "pkg-config"
    "bsdmainutils"
    "bison"
    "curl"
    "g++-mingw-w64-x86-64"
    "mingw-w64-x86-64-dev"
    "libgmp-dev"
    "libdb4.8-dev"
    "libdb4.8++"
)

# Function to check and install missing packages
install_if_missing() {
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
        1) prefix="i686-pc-linux-gnu";;
        2) prefix="x86_64-pc-linux-gnu";;
        3) prefix="x86_64-w64-mingw32";;
        4) prefix="x86_64-apple-darwin19";;
        5) prefix="arm-linux-gnueabihf";;
        6) prefix="aarch64-linux-gnu";;
        7) echo -e "${YELLOW}Exiting...${NC}"; exit 0;;
        *) echo -e "${RED}Invalid option!${NC}"; exit 1;;
    esac

    # Install necessary packages after a choice is made
    install_if_missing

    # Run the build steps
    echo -e "${CYAN}Configuring for ${YELLOW}$prefix${CYAN}...${NC}"
    cd depends || { echo -e "${RED}Failed to change directory to 'depends'${NC}"; exit 1; }
    make -j$(nproc) || { echo -e "${RED}Failed to build dependencies${NC}"; exit 1; }
    cd .. || { echo -e "${RED}Failed to change back to parent directory${NC}"; exit 1; }

    # Add the Bitcoin PPA for Berkeley DB 4.8 and install it
    echo -e "${CYAN}Adding Bitcoin PPA and installing Berkeley DB 4.8...${NC}"
    sudo add-apt-repository -y ppa:bitcoin/bitcoin
    sudo apt-get update -y
    sudo apt-get install -y libdb4.8-dev libdb4.8++

    # Configure the project with CONFIG_SITE and force use of Berkeley DB 4.8
    CONFIG_SITE=$PWD/depends/$prefix/share/config.site ./configure --prefix=/ --disable-bench --disable-tests || { echo -e "${RED}Failed to configure${NC}"; exit 1; }
    make -j$(nproc) || { echo -e "${RED}Failed to build the project${NC}"; exit 1; }
    
    echo -e "${GREEN}Build completed successfully for ${YELLOW}$prefix${GREEN}!${NC}"
}

# Display the header
show_header

# Display the menu and get the user's choice
show_menu
read -p "Enter your choice [1-7]: " choice

# Call the function with the user's choice
configure_project $choice
