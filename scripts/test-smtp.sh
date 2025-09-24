#!/bin/bash

# SMTP Server Test Script
# Tests connectivity and authentication to Mailgun SMTP server

# SMTP Configuration
SMTP_SERVER="smtp.eu.mailgun.org"
SMTP_PORT="587"
SMTP_LOGIN="karl@smtp.social.ubdm.io"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "SMTP Server Test Script"
echo "=========================================="
echo "Server: $SMTP_SERVER"
echo "Port: $SMTP_PORT"
echo "Login: $SMTP_LOGIN"
echo "=========================================="

# Function to test basic connectivity
test_connectivity() {
    echo -e "${YELLOW}Testing basic connectivity...${NC}"
    
    # Test if server is reachable on the specified port
    if command -v nc >/dev/null 2>&1; then
        if nc -z -w5 "$SMTP_SERVER" "$SMTP_PORT" 2>/dev/null; then
            echo -e "${GREEN}✓ Server is reachable on port $SMTP_PORT${NC}"
            return 0
        else
            echo -e "${RED}✗ Cannot reach server on port $SMTP_PORT${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠ netcat not available, skipping connectivity test${NC}"
        return 0
    fi
}

# Function to test SMTP using curl
test_smtp_curl() {
    echo -e "${YELLOW}Testing SMTP with curl...${NC}"
    
    # Check if password is provided
    if [ -z "$SMTP_PASSWORD" ]; then
        echo -e "${RED}✗ SMTP_PASSWORD environment variable not set${NC}"
        echo "Please set it with: export SMTP_PASSWORD='your_password'"
        return 1
    fi
    
    # Test SMTP authentication and capability
    echo "Attempting SMTP connection..."
    
    # Create a temporary file for the email
    TEMP_EMAIL=$(mktemp)
    cat > "$TEMP_EMAIL" << EOF
From: $SMTP_LOGIN
To: test@example.com
Subject: SMTP Test Email
Date: $(date -R)

This is a test email to verify SMTP connectivity.
Sent at: $(date)
EOF

    # Test SMTP with curl
    curl_output=$(curl -s --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
        --ssl \
        --tlsv1.2 \
        --mail-from "$SMTP_LOGIN" \
        --mail-rcpt "test@example.com" \
        --upload-file "$TEMP_EMAIL" \
        --user "$SMTP_LOGIN:$SMTP_PASSWORD" \
        --verbose 2>&1)
    
    curl_exit_code=$?
    
    # Clean up temp file
    rm -f "$TEMP_EMAIL"
    
    if [ $curl_exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ SMTP test successful${NC}"
        echo "Connection details:"
        echo "$curl_output" | grep -E "(Connected to|SSL connection|AUTH|250|221)"
        return 0
    else
        echo -e "${RED}✗ SMTP test failed${NC}"
        echo "Error details:"
        echo "$curl_output"
        return 1
    fi
}

# Function to test SMTP capabilities
test_smtp_capabilities() {
    echo -e "${YELLOW}Testing SMTP capabilities...${NC}"
    
    if command -v telnet >/dev/null 2>&1; then
        echo "Connecting to SMTP server to check capabilities..."
        (
            echo "EHLO test.local"
            sleep 1
            echo "QUIT"
            sleep 1
        ) | telnet "$SMTP_SERVER" "$SMTP_PORT" 2>/dev/null | grep -E "(250|220|221|STARTTLS|AUTH)"
    else
        echo -e "${YELLOW}⚠ telnet not available, skipping capabilities test${NC}"
    fi
}

# Function to show usage
show_usage() {
    echo ""
    echo "Usage:"
    echo "1. Set your SMTP password: export SMTP_PASSWORD='your_mailgun_password'"
    echo "2. Run the script: ./test-smtp.sh"
    echo ""
    echo "Available options:"
    echo "  --connectivity-only    Test only basic connectivity"
    echo "  --capabilities-only    Test only SMTP capabilities"
    echo "  --help                Show this help message"
}

# Main execution
case "${1:-}" in
    --connectivity-only)
        test_connectivity
        ;;
    --capabilities-only)
        test_smtp_capabilities
        ;;
    --help)
        show_usage
        ;;
    *)
        # Run all tests
        test_connectivity
        echo ""
        test_smtp_capabilities
        echo ""
        test_smtp_curl
        echo ""
        echo "=========================================="
        echo "Test completed!"
        echo "=========================================="
        show_usage
        ;;
esac
