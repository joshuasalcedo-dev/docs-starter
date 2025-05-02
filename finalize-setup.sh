#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Setup Finalization ===${NC}"

# Make all scripts executable
chmod +x *.sh
chmod +x deployment/*.sh 2>/dev/null

# Create required directories
mkdir -p "$HOME/.docs/documentation"

# Build the application
echo -e "${GREEN}Building the application...${NC}"
./mvnw clean package -DskipTests

echo -e "\n${GREEN}Setup completed!${NC}"
echo -e "${BLUE}Your Documentation App is ready to use.${NC}"
echo -e "${YELLOW}To run the application:${NC}"
echo -e "  Local mode: ./run-docs-app.sh"
echo -e "  Docker mode: docker-compose up -d"
echo -e "  Production mode: ./deploy-production.sh"
echo -e "\n${YELLOW}Additional utilities:${NC}"
echo -e "  Backup/restore: ./backup-docs.sh"
echo -e "  Install as service: sudo ./install-as-service.sh"
echo -e "  Configure Nginx: sudo ./setup-nginx.sh"
echo -e "  Generate API token: ./generate-api-token.sh"
