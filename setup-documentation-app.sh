#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Setup Wrapper ===${NC}"
echo -e "${YELLOW}This script will run all necessary setup scripts${NC}"

# Make all scripts executable
chmod +x setup-docs-app.sh
chmod +x setup-docs-app-continued.sh
chmod +x setup-docs-app-continued2.sh

# Run the scripts in sequence
echo -e "\n${GREEN}Running first setup script...${NC}"
./setup-docs-app.sh

echo -e "\n${GREEN}Running second setup script...${NC}"
./setup-docs-app-continued.sh

echo -e "\n${GREEN}Running final setup script...${NC}"
./setup-docs-app-continued2.sh

echo -e "\n${BLUE}All setup scripts completed successfully!${NC}"
echo -e "${YELLOW}To run the application, execute: ./run-docs-app.sh${NC}"
