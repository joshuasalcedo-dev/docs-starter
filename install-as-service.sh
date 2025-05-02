#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Service Installer ===${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root or with sudo${NC}"
  exit 1
fi

# Get the current directory and user
APP_DIR=$(pwd)
CURRENT_USER=$(logname || echo $SUDO_USER)

if [ -z "$CURRENT_USER" ]; then
    echo -e "${YELLOW}Could not determine current user, using current directory owner${NC}"
    CURRENT_USER=$(stat -c '%U' .)
fi

echo -e "${GREEN}Installing Documentation App as a systemd service${NC}"
echo -e "${YELLOW}App directory: $APP_DIR${NC}"
echo -e "${YELLOW}User: $CURRENT_USER${NC}"

# Build the application
echo -e "${GREEN}Building the application...${NC}"
sudo -u $CURRENT_USER ./mvnw clean package -DskipTests

# Create the service file
echo -e "${GREEN}Creating systemd service file...${NC}"
SERVICE_FILE="./deployment/documentation-app.service"
DEST_FILE="/etc/systemd/system/documentation-app.service"

# Replace placeholders
sed "s|APP_DIR|$APP_DIR|g; s|APP_USER|$CURRENT_USER|g" $SERVICE_FILE > /tmp/documentation-app.service
mv /tmp/documentation-app.service $DEST_FILE

# Reload systemd
echo -e "${GREEN}Reloading systemd...${NC}"
systemctl daemon-reload

# Enable and start the service
echo -e "${GREEN}Enabling and starting the service...${NC}"
systemctl enable documentation-app.service
systemctl start documentation-app.service

echo -e "\n${GREEN}Installation completed successfully!${NC}"
echo -e "${BLUE}The application is now running as a system service${NC}"
echo -e "${YELLOW}To check status: sudo systemctl status documentation-app${NC}"
echo -e "${YELLOW}To stop: sudo systemctl stop documentation-app${NC}"
echo -e "${YELLOW}To start: sudo systemctl start documentation-app${NC}"
echo -e "${YELLOW}Logs can be viewed with: sudo journalctl -u documentation-app${NC}"
