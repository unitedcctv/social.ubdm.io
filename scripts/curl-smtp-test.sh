#!/bin/bash

# Simple curl SMTP test script
# Usage: SMTP_PASSWORD='your_password' ./curl-smtp-test.sh

SMTP_SERVER="smtp.eu.mailgun.org"
SMTP_PORT="587"
SMTP_LOGIN="karl@smtp.social.ubdm.io"

if [ -z "$SMTP_PASSWORD" ]; then
    echo "Error: SMTP_PASSWORD environment variable not set"
    echo "Usage: SMTP_PASSWORD='your_password' ./curl-smtp-test.sh"
    echo ""
    echo "For Mailgun, use your domain's SMTP password from:"
    echo "https://app.mailgun.com/app/sending/domains"
    exit 1
fi

echo "Testing SMTP server: $SMTP_SERVER:$SMTP_PORT"
echo "Login: $SMTP_LOGIN"
echo "Password: ${SMTP_PASSWORD:0:4}******* (first 4 chars shown)"

# Create test email content
cat > test-email.txt << EOF
From: $SMTP_LOGIN
To: test@example.com
Subject: SMTP Test - $(date)

This is a test email to verify SMTP connectivity.
Timestamp: $(date)
EOF

# Test SMTP with curl
echo "Sending test email via curl..."
curl --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
     --ssl \
     --tlsv1.2 \
     --mail-from "$SMTP_LOGIN" \
     --mail-rcpt "test@example.com" \
     --upload-file test-email.txt \
     --user "$SMTP_LOGIN:$SMTP_PASSWORD" \
     --verbose

echo "Exit code: $?"

# Clean up
rm -f test-email.txt
