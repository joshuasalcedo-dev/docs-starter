#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Documentation App API Token Generator ===${NC}"

# Check if OpenSSL is available
if ! command -v openssl &> /dev/null; then
    echo -e "${RED}Error: OpenSSL is required to generate tokens${NC}"
    exit 1
fi

# Default secret key
SECRET_KEY="${JWT_SECRET:-defaultSecretKeyForDocumentationAppShouldBeChanged}"

# Get username
read -p "Enter username for the token: " USERNAME
if [ -z "$USERNAME" ]; then
    echo -e "${YELLOW}No username provided. Using 'api-user' as default${NC}"
    USERNAME="api-user"
fi

# Generate a simple JWT token
# Note: This is a simplified implementation for demonstration purposes only
HEADER='{"alg":"HS256","typ":"JWT"}'
HEADER_BASE64=$(echo -n "$HEADER" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Current time and expiration (24 hours)
CURRENT_TIME=$(date +%s)
EXPIRATION_TIME=$((CURRENT_TIME + 86400))
PAYLOAD="{\"sub\":\"$USERNAME\",\"iat\":$CURRENT_TIME,\"exp\":$EXPIRATION_TIME}"
PAYLOAD_BASE64=$(echo -n "$PAYLOAD" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Create signature
SIGNATURE_INPUT="$HEADER_BASE64.$PAYLOAD_BASE64"
SIGNATURE=$(echo -n "$SIGNATURE_INPUT" | openssl dgst -sha256 -hmac "$SECRET_KEY" -binary | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Combine to form JWT
TOKEN="$HEADER_BASE64.$PAYLOAD_BASE64.$SIGNATURE"

echo -e "\n${GREEN}API Token generated successfully!${NC}"
echo -e "${YELLOW}Token expires in 24 hours${NC}"
echo -e "${BLUE}Token:${NC} $TOKEN"
echo -e "\n${GREEN}Example API usage:${NC}"
echo "curl -H \"Authorization: Bearer $TOKEN\" http://localhost:8080/api/documentation"

# Save token to file
echo -n "$TOKEN" > api-token.txt
echo -e "\n${GREEN}Token also saved to api-token.txt${NC}"
