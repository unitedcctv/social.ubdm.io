# Mastodon Deployment Guide

This guide covers both local development and production deployment of your Mastodon instance.

## 📋 Table of Contents

- [Local Development Setup](#local-development-setup)
- [Production Deployment](#production-deployment)
- [Environment Configuration](#environment-configuration)
- [Troubleshooting](#troubleshooting)

---

## 🏠 Local Development Setup

### Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available
- Ports 3000 and 4000 available

### Step 1: Environment Setup

The local setup uses `.env.local` for development-specific configuration and includes its own database:

```bash
# Verify .env.local exists and contains local settings
cat .env.local
```

Key local settings:
- `LOCAL_DOMAIN=localhost:3000`
- Development-only secrets (not secure)
- Local database configuration (`DB_HOST=db`, `DB_PASS=postgres`)
- Local SMTP server configuration

### Step 2: Initial Setup

Run the Mastodon setup wizard (override file is automatically loaded):

```bash
sudo docker compose run --rm web bundle exec rake mastodon:setup
```

This will:
- Create database schema
- Generate secure keys (if needed)
- Create admin user
- Test database and Redis connections

### Step 3: Start Services

Start dependencies first (database and Redis):

```bash
sudo docker compose --profile deps up -d
```

Then start all Mastodon services:

```bash
sudo docker compose up -d
```

### Step 4: Access Local Instance

- **Web Interface**: http://localhost:3000
- **Streaming API**: http://localhost:4000
- **Admin Panel**: http://localhost:3000/admin

### Step 5: Stop Services

To stop all services:

```bash
sudo docker compose down
```

To stop and remove volumes (reset everything):

```bash
sudo docker compose down -v
```

---

## 🚀 Production Deployment

### Prerequisites

- Production server with Docker and Docker Compose
- Traefik reverse proxy running with `traefik-public` network
- Existing PostgreSQL container (`pgvector/pgvector:pg12`)
- Domain name configured and pointing to your server

### Step 1: Database Setup

Follow the [database-setup.md](./database-setup.md) guide to create the Mastodon database in your existing PostgreSQL container.

### Step 2: Environment Configuration

Update your main `.env` file with production values:

```bash
# Stack configuration
STACK_NAME=mastodon
DOMAIN=your-domain.com

# Database (use your existing PostgreSQL credentials)
POSTGRES_HOST=db
POSTGRES_DB=mastodon
POSTGRES_USER=your_postgres_user
POSTGRES_PASSWORD=your_postgres_password
POSTGRES_PORT=5432
```

Update `.env.production` with your domain:

```bash
# Change localhost to your actual domain
LOCAL_DOMAIN=your-domain.com
```

### Step 3: Initial Setup

Run the Mastodon setup wizard:

```bash
sudo docker compose run --rm web bundle exec rake mastodon:setup
```

### Step 4: Deploy Services

Start all services:

```bash
sudo docker compose up -d
```

### Step 5: Deploy to Production Server

Use the automated deployment script to deploy your Mastodon configuration:

```bash
# From your local development machine
./scripts/deploy-to-production.sh
```

**What the deployment script does:**
- Creates the remote directory structure
- Copies `docker-compose.yml` to the server
- Copies `.env.production` as `.env` to the server
- **Copies `update-mastodon.sh` script** for future updates
- Sets proper executable permissions

### Step 6: Verify Deployment

SSH to your production server and verify:

```bash
ssh karl@188.245.225.192
cd /home/karl/mastodon

# Check that all files are present
ls -la
# Should show: docker-compose.yml, .env, update-mastodon.sh

# Start the services
sudo docker compose up -d

# Check that all services are running
sudo docker compose ps
```

Check Traefik routing:
- Your domain should be accessible via HTTPS
- SSL certificates should be automatically generated

---

## ⚙️ Environment Configuration

### Local Development (`.env.local`)

```bash
LOCAL_DOMAIN=localhost:3000
SINGLE_USER_MODE=false
SECRET_KEY_BASE=local_dev_secret_key_base_for_testing_only_not_secure
OTP_SECRET=local_dev_otp_secret_for_testing_only_not_secure
VAPID_PRIVATE_KEY=local_dev_vapid_private_key_for_testing_only
VAPID_PUBLIC_KEY=local_dev_vapid_public_key_for_testing_only
DB_HOST=db
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASS=
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=
SMTP_SERVER=localhost
SMTP_PORT=1025
SMTP_LOGIN=
SMTP_PASSWORD=
SMTP_AUTH_METHOD=plain
SMTP_OPENSSL_VERIFY_MODE=none
SMTP_FROM_ADDRESS=Mastodon Local <notifications@localhost>
```

### Production (`.env.production`)

```bash
LOCAL_DOMAIN=your-domain.com
SINGLE_USER_MODE=false
SECRET_KEY_BASE=your_secure_secret_key_base
OTP_SECRET=your_secure_otp_secret
VAPID_PRIVATE_KEY=your_vapid_private_key
VAPID_PUBLIC_KEY=your_vapid_public_key
DB_HOST=${POSTGRES_HOST:-db}
DB_PORT=${POSTGRES_PORT:-5432}
DB_NAME=${POSTGRES_DB}
DB_USER=${POSTGRES_USER}
DB_PASS=${POSTGRES_PASSWORD}
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=
SMTP_SERVER=your-smtp-server.com
SMTP_PORT=587
SMTP_LOGIN=your-smtp-username
SMTP_PASSWORD=your_smtp_password
SMTP_AUTH_METHOD=plain
SMTP_OPENSSL_VERIFY_MODE=peer
SMTP_FROM_ADDRESS=Your Instance <notifications@your-domain.com>
```

### Main Environment (`.env`)

```bash
# Stack configuration for Traefik labels
STACK_NAME=mastodon
DOMAIN=your-domain.com
COMPOSE_PROJECT_NAME=mastodon

# Database credentials (production)
POSTGRES_HOST=db
POSTGRES_DB=mastodon
POSTGRES_USER=your_postgres_user
POSTGRES_PASSWORD=your_postgres_password
POSTGRES_PORT=5432
```

---

## 🔧 Troubleshooting

### Common Local Issues

**Port conflicts:**
```bash
# Check what's using ports 3000/4000
lsof -i :3000
lsof -i :4000
```

**Database connection issues:**
```bash
# Check if database container is running
docker ps | grep ub_staging_stack-db-1
```

**Volume mount errors:**
```bash
# Ensure public/system directory exists
mkdir -p public/system
```

### Common Production Issues

**Traefik network not found:**
```bash
# Create traefik-public network if it doesn't exist
docker network create traefik-public
```

**SSL certificate issues:**
- Verify domain DNS points to your server
- Check Traefik logs: `docker logs traefik_container_name`
- Ensure ports 80 and 443 are open

**Database connection issues:**
```bash
# Test database connection
sudo docker exec -it ub_staging_stack-db-1 psql -U postgres -d mastodon -c "SELECT version();"
```

### Update Script Issues

**Script not executable:**
```bash
# Make the update script executable
chmod +x update-mastodon.sh
```

**Backup directory not found:**
```bash
# Create the backup directory if it doesn't exist
mkdir -p public/system/backups
```

**Update script fails during migration:**
```bash
# Check migration status
sudo docker compose run --rm web bundle exec rake db:migrate:status

# Run migrations manually if needed
sudo docker compose run --rm -e RAILS_ENV=production web bundle exec rails db:migrate
```

**Asset precompilation fails:**
```bash
# Clear assets and try again
sudo docker compose run --rm -e RAILS_ENV=production web bundle exec rails assets:clobber
sudo docker compose run --rm -e RAILS_ENV=production web bundle exec rails assets:precompile
```

### Service Health Checks

**Check all services:**
```bash
# Local
sudo docker compose -f docker-compose.local.yml ps

# Production  
sudo docker compose ps
```

**View logs:**
```bash
# Local
sudo docker compose -f docker-compose.local.yml logs -f web

# Production
sudo docker compose logs -f web
```

### Performance Optimization

**For production, consider:**
- Increasing PostgreSQL shared_buffers
- Setting up Redis persistence
- Configuring log rotation
- Setting up monitoring (Prometheus/Grafana)

---

## 📚 Additional Resources

- [Mastodon Documentation](https://docs.joinmastodon.org/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

## 🔄 Maintenance Commands

### Database Maintenance

#### Mastodon Built-in Backup System (Recommended)

```bash
# Create a complete Mastodon backup (includes database, media files, etc.)
sudo docker compose run --rm -e RAILS_ENV=production web bundle exec rake mastodon:backup:create

# List available backups
ls -la public/system/backups/

# Restore from a backup
sudo docker compose run --rm -e RAILS_ENV=production web bundle exec rake mastodon:backup:restore BACKUP_FILE=backup-20241224-123456.tar.gz
```

#### Manual Database Backup

```bash
# Backup database only
sudo docker exec ub_staging_stack-db-1 pg_dump -U postgres mastodon > mastodon_backup.sql

# Restore database only
sudo docker exec -i ub_staging_stack-db-1 psql -U postgres mastodon < mastodon_backup.sql
```

#### Backup Management

The `update-mastodon.sh` script automatically:
- Creates backups before each update
- Keeps only the last 5 backups to save disk space
- Stores backups in `public/system/backups/` with timestamps

**Manual backup cleanup:**
```bash
# Remove backups older than 30 days
find public/system/backups/ -name "*.tar.gz" -mtime +30 -delete
```

### Update Mastodon

#### Automated Update Script (Recommended)

Use the included `update-mastodon.sh` script for safe, automated updates:

```bash
# Update to a specific version (e.g., v4.4.5)
./update-mastodon.sh v4.4.5
```

**What the script does:**
1. **Creates automatic backup** using Mastodon's built-in backup system
2. **Prunes old backups** (keeps only the last 5 backups)
3. **Updates docker-compose.yml** with the new version
4. **Pulls new Docker images**
5. **Stops current containers** gracefully
6. **Runs database migrations** automatically
7. **Precompiles assets** for the new version
8. **Restarts all services**

**Backup location:** `public/system/backups/`

#### Manual Update Process

If you prefer manual updates:

```bash
# 1. Create backup first
sudo docker compose run --rm -e RAILS_ENV=production web bundle exec rake mastodon:backup:create

# 2. Update docker-compose.yml version manually
# Edit docker-compose.yml and change the image tags

# 3. Pull latest images
sudo docker compose pull

# 4. Stop services
sudo docker compose down

# 5. Run database migrations
sudo docker compose run --rm -e RAILS_ENV=production web bundle exec rails db:migrate

# 6. Precompile assets
sudo docker compose run --rm -e RAILS_ENV=production web bundle exec rails assets:precompile

# 7. Restart services
sudo docker compose up -d
```


### Main Traefik Dashboard

Traefik UI: `https://traefik.ubdm.io`

### Production

Adminer: `https://adminer.ubdm.io`

### Staging

Adminer: `https://adminer.staging.ubdm.io`