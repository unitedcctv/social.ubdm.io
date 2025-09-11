# Mastodon Database Setup Instructions

This guide explains how to create a Mastodon database in your existing PostgreSQL container.

## Prerequisites

- Existing PostgreSQL container running `pgvector/pgvector:pg12`
- Docker access to your production server
- PostgreSQL credentials (username, password, database name)

## Step 1: Find Your Database Container

First, identify your PostgreSQL container name:

```bash
docker ps | grep pgvector
```

Look for the container running `pgvector/pgvector:pg12` and note its name.

## Step 2: Connect to PostgreSQL Container

Replace `YOUR_CONTAINER_NAME` with the actual container name from Step 1:

```bash
docker exec -it YOUR_CONTAINER_NAME psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
```

## Step 3: Create Mastodon Database

Once connected to the PostgreSQL prompt, run:

```sql
CREATE DATABASE mastodon;
\q
```

## Alternative: One-Line Command

If you prefer a single command (replace with your actual values):

```bash
docker exec -it YOUR_CONTAINER_NAME psql -U your_postgres_user -c "CREATE DATABASE mastodon;"
```

## Step 4: Update Environment Variables

After creating the database, update your `.env` file with the database connection details:

```bash
# Database Configuration
POSTGRES_HOST=db  # or your actual database container name
POSTGRES_DB=mastodon
POSTGRES_USER=your_existing_user
POSTGRES_PASSWORD=your_existing_password
POSTGRES_PORT=5432
```

## What This Setup Does

- ✅ Creates a separate `mastodon` database within your existing PostgreSQL instance
- ✅ Keeps Mastodon data isolated from your other applications  
- ✅ Uses the same PostgreSQL server (no resource duplication)
- ✅ Leverages existing pgvector extensions for future features

## Verification

To verify the database was created successfully:

```bash
docker exec -it YOUR_CONTAINER_NAME psql -U ${POSTGRES_USER} -c "\l" | grep mastodon
```

You should see the `mastodon` database listed.

## Next Steps

After completing these steps:

1. Run the Mastodon setup: `docker-compose run web bundle exec rake mastodon:setup`
2. The setup will automatically create all necessary tables in the new `mastodon` database
3. Deploy your Mastodon instance using your production docker-compose configuration

## Troubleshooting

### Permission Issues
If you encounter permission errors, ensure your PostgreSQL user has database creation privileges:

```sql
ALTER USER your_postgres_user CREATEDB;
```

### Connection Issues
If you can't connect to the database container:
- Verify the container is running: `docker ps`
- Check the container logs: `docker logs YOUR_CONTAINER_NAME`
- Ensure you're using the correct username and database name from your environment variables
