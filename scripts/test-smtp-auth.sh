#!/bin/bash

# SMTP Authentication Test Script
# Tests different authentication methods for Mailgun

SMTP_SERVER="smtp.eu.mailgun.org"
SMTP_PORT="587"
SMTP_LOGIN="karl@smtp.social.ubdm.io"

if [ -z "$SMTP_PASSWORD" ]; then
    echo "Error: SMTP_PASSWORD environment variable not set"
    echo "Usage: SMTP_PASSWORD='your_password' ./test-smtp-auth.sh"
    echo ""
    echo "For Mailgun SMTP, you need:"
    echo "1. Username: postmaster@your-domain.com (or any valid email on your domain)"
    echo "2. Password: Your domain's SMTP password from Mailgun dashboard"
    echo ""
    echo "Alternative usernames to try:"
    echo "- postmaster@social.ubdm.io"
    echo "- karl@social.ubdm.io"
    exit 1
fi

echo "=== SMTP Authentication Test ==="
echo "Server: $SMTP_SERVER:$SMTP_PORT"
echo "Username: $SMTP_LOGIN"
echo "Password: ${SMTP_PASSWORD:0:4}******* (showing first 4 chars)"
echo ""

# Test 1: Basic connectivity and STARTTLS
echo "Test 1: Testing STARTTLS capability..."
curl -v --connect-timeout 10 \
     --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
     --ssl \
     --tlsv1.2 \
     --user "$SMTP_LOGIN:$SMTP_PASSWORD" \
     --mail-from "$SMTP_LOGIN" \
     --mail-rcpt "test@example.com" \
     --upload-file /dev/null 2>&1 | grep -E "(Connected|STARTTLS|AUTH|250|535|Authentication)"

echo ""
echo "=== Common Mailgun Issues ==="
echo "1. Wrong password - Use SMTP password from Mailgun dashboard, not account password"
echo "2. Wrong username format - Try 'postmaster@social.ubdm.io' instead"
echo "3. Domain not verified - Check domain status in Mailgun"
echo "4. IP restrictions - Check if your IP is allowed"
echo ""
echo "To get correct credentials:"
echo "1. Go to https://app.mailgun.com/app/sending/domains"
echo "2. Click on your domain (social.ubdm.io)"
echo "3. Go to 'Domain Settings' > 'SMTP credentials'"
echo "4. Use the username and password shown there"
