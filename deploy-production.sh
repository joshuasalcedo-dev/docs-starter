#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Production Deployment ===${NC}"

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: Docker and Docker Compose are required for production deployment${NC}"
    exit 1
fi

# Build the application with production profile
echo -e "${GREEN}Building the application with production profile...${NC}"
./mvnw clean package -Pproduction -DskipTests

# Build and start Docker containers
echo -e "${GREEN}Building and starting Docker containers...${NC}"
docker-compose -f docker-compose.prod.yml up --build -d

echo -e "\n${GREEN}Deployment completed successfully!${NC}"
echo -e "${BLUE}The application is now running at: http://localhost${NC}"
echo -e "${YELLOW}Data is stored in: $HOME/.docs/documentation${NC}"
