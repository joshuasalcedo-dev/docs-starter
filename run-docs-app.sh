#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App Runner ===${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker is not installed. Running in local mode.${NC}"
    echo -e "${GREEN}Building with Maven...${NC}"
    ./mvnw clean package
    
    echo -e "${GREEN}Starting application...${NC}"
    java -jar target/*.jar
else
    echo -e "${GREEN}Docker is installed. Running with Docker Compose...${NC}"
    
    # Create necessary directories
    mkdir -p "$HOME/.docs/documentation"
    
    # Build and start the containers
    docker-compose up --build -d
    
    echo -e "${GREEN}Application is running at http://localhost:8080${NC}"
    echo -e "${YELLOW}To stop the application, run: docker-compose down${NC}"
fi
