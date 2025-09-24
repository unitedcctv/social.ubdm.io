#!/usr/bin/env bash
#
# Mastodon update script for Docker Compose
# Includes backup, migrations, asset precompilation, restart.
# Keeps only the last 5 backups.
#
# Usage:
#   ./update-mastodon.sh v4.4.5
#

set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <mastodon-version>"
  echo "Example: $0 v4.4.5"
  exit 1
fi

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_DIR="public/system/backups"
KEEP_BACKUPS=5

echo ">>> Updating Mastodon to version $VERSION"
echo ">>> Backup timestamp: $TIMESTAMP"

# 1. Run Mastodon backup
echo ">>> Creating Mastodon backup..."
sudo docker compose run --rm -e RAILS_ENV=production web bundle exec rake mastodon:backup:create

if [[ ! -d "$BACKUP_DIR" ]]; then
  echo "!!! Backup directory $BACKUP_DIR not found. Check your Mastodon install."
else
  echo ">>> Backup created. Stored under $BACKUP_DIR"

  # 2. Prune old backups
  echo ">>> Pruning old backups, keeping the last $KEEP_BACKUPS"
  cd "$BACKUP_DIR"
  ls -1t *.tar.gz | tail -n +$((KEEP_BACKUPS+1)) | xargs -r rm -f
  cd - >/dev/null
fi

# 3. Update docker-compose.yml to use new version
echo ">>> Updating docker-compose.yml images to $VERSION"
sed -i.bak -E "s|(ghcr.io/mastodon/mastodon:)([a-zA-Z0-9\.\-]+)|\1$VERSION|g" docker-compose.yml

# 4. Pull new images
echo ">>> Pulling new Docker images..."
sudo docker compose pull

# 5. Stop current containers
echo ">>> Stopping current containers..."
sudo docker compose down

# 6. Run database migrations
echo ">>> Running database migrations..."
sudo docker compose run --rm -e RAILS_ENV=production web bundle exec rails db:migrate

# 7. Precompile assets
echo ">>> Precompiling assets..."
sudo docker compose run --rm -e RAILS_ENV=production web bundle exec rails assets:precompile

# 8. Bring services back up
echo ">>> Starting services..."
sudo docker compose up -d

echo ">>> Mastodon has been updated to $VERSION"
echo ">>> Please check logs to confirm everything is running:"
echo "    sudo docker compose logs -f web"

