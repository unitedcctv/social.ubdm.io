#!/bin/bash

# Deploy Mastodon configuration to production server
# Usage: ./scripts/deploy-to-production.sh

set -e

# Configuration (gitignored)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_CONF="$SCRIPT_DIR/deploy.conf"

if [[ ! -f "$DEPLOY_CONF" ]]; then
  echo "ERROR: Missing $DEPLOY_CONF"
  echo "Create it by copying: $SCRIPT_DIR/deploy.conf.example -> $DEPLOY_CONF"
  exit 1
fi

# shellcheck source=/dev/null
source "$DEPLOY_CONF"

if [[ -z "${PRODUCTION_SERVER:-}" || -z "${REMOTE_DIR:-}" ]]; then
  echo "ERROR: PRODUCTION_SERVER and REMOTE_DIR must be set in $DEPLOY_CONF"
  exit 1
fi

echo "🚀 Deploying Mastodon configuration to production server..."

# Create remote directory if it doesn't exist
echo "📁 Creating remote directory..."
ssh $PRODUCTION_SERVER "mkdir -p $REMOTE_DIR"

# Copy docker-compose.yml
echo "📋 Copying docker-compose.yml..."
scp docker-compose.yml $PRODUCTION_SERVER:$REMOTE_DIR/

# Copy .env.production and rename to .env
echo "⚙️  Copying .env.production as .env..."
scp .env.production $PRODUCTION_SERVER:$REMOTE_DIR/.env

# Copy update-mastodon.sh script
echo "🔄 Copying update-mastodon.sh script..."
scp scripts/update-mastodon.sh $PRODUCTION_SERVER:$REMOTE_DIR/
ssh $PRODUCTION_SERVER "chmod +x $REMOTE_DIR/update-mastodon.sh"

echo "✅ Deployment complete!"
echo ""
echo "Next steps on the production server:"
echo "1. SSH to the server: ssh $PRODUCTION_SERVER"
echo "2. Navigate to the directory: cd $REMOTE_DIR"
echo "3. Start the services: sudo docker compose up -d or"
echo "4. Restart the services: sudo docker compose restart"
echo "5. Check the status of the services: sudo docker compose ps"
echo "6. Check the logs of the services: sudo docker compose logs -f"
echo "7. To update Mastodon: ./update-mastodon.sh <version> (e.g., ./update-mastodon.sh v4.4.5)"
echo ""
echo "Production URLs:"
echo "- Traefik Dashboard: https://traefik.ubdm.io"
echo "- Adminer: https://adminer.ubdm.io"
