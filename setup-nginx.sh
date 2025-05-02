#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Nginx Setup ===${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root or with sudo${NC}"
  exit 1
fi

# Check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    echo -e "${YELLOW}Nginx is not installed. Installing...${NC}"
    apt-get update
    apt-get install -y nginx
fi

# Get domain name
read -p "Enter your domain name (e.g., documentation.example.com): " DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ]; then
    echo -e "${YELLOW}No domain provided. Using documentation.example.com as default${NC}"
    DOMAIN_NAME="documentation.example.com"
fi

# Update Nginx config
echo -e "${GREEN}Creating Nginx configuration...${NC}"
NGINX_CONF_SRC="./deployment/nginx/documentation-app.conf"
NGINX_CONF_DEST="/etc/nginx/sites-available/documentation-app"

# Replace domain name
sed "s/documentation.example.com/$DOMAIN_NAME/g" $NGINX_CONF_SRC > $NGINX_CONF_DEST

# Enable the site
echo -e "${GREEN}Enabling the site...${NC}"
ln -sf $NGINX_CONF_DEST /etc/nginx/sites-enabled/

# Test configuration
echo -e "${GREEN}Testing Nginx configuration...${NC}"
nginx -t

if [ $? -ne 0 ]; then
    echo -e "${RED}Nginx configuration test failed. Please check the error message above.${NC}"
    exit 1
fi

# Restart Nginx
echo -e "${GREEN}Restarting Nginx...${NC}"
systemctl restart nginx

echo -e "\n${GREEN}Nginx setup completed successfully!${NC}"
echo -e "${BLUE}Your Documentation App should now be accessible at: http://$DOMAIN_NAME${NC}"
echo -e "${YELLOW}Don't forget to set up DNS records to point $DOMAIN_NAME to your server's IP address.${NC}"
