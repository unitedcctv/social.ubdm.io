# Mastodon Environment Configuration

This document explains the environment variables used in the Mastodon instance configuration.

## 🌐 Domain Configuration

### `LOCAL_DOMAIN`
**Value:** `example.com`  
**Description:** The domain name that identifies your Mastodon instance. This is the primary identifier for your server in the fediverse.  
**⚠️ Warning:** Changing this after setup will break federation and user accounts.

### `SINGLE_USER_MODE`
**Value:** `false`  
**Description:** When enabled, disables new user registrations and redirects the landing page to the admin's public profile.  
**Options:** `true` or `false`

## 🔐 Security Keys

### `SECRET_KEY_BASE`
**Value:** `XXXXXXXX` (hidden for security)  
**Description:** Rails secret key used for encrypting sessions and other sensitive data.  
**⚠️ Security:** Keep this secret and never share it publicly.

### `OTP_SECRET`
**Value:** `XXXXXXXX` (hidden for security)  
**Description:** Secret key used for generating one-time passwords (2FA).  
**⚠️ Security:** Keep this secret and never share it publicly.

## 🔔 Web Push Notifications (VAPID)

### `VAPID_PRIVATE_KEY` & `VAPID_PUBLIC_KEY`
**Values:** `XXXXXXXX` (hidden for security)  
**Description:** VAPID keys used for web push notifications. These allow your Mastodon instance to send push notifications to users' browsers.  
**Note:** Generated as a pair - both are required for push notifications to work.

## 🗄️ Database Configuration (PostgreSQL)

### `DB_HOST`
**Value:** `db`  
**Description:** PostgreSQL database hostname. In Docker setup, this refers to the database service name.

### `DB_PORT`
**Value:** `5432`  
**Description:** PostgreSQL database port (default PostgreSQL port).

### `DB_NAME`
**Value:** `postgres`  
**Description:** Name of the PostgreSQL database to use for Mastodon data.

### `DB_USER`
**Value:** `postgres`  
**Description:** PostgreSQL username for database connection.

### `DB_PASS`
**Value:** *(empty)*  
**Description:** PostgreSQL password. Empty in this setup (using trust authentication in Docker).

## 🔄 Cache Configuration (Redis)

### `REDIS_HOST`
**Value:** `redis`  
**Description:** Redis server hostname. In Docker setup, this refers to the Redis service name.

### `REDIS_PORT`
**Value:** `6379`  
**Description:** Redis server port (default Redis port).

### `REDIS_PASSWORD`
**Value:** *(empty)*  
**Description:** Redis password. Empty in this setup (no authentication configured).

## 📧 Email Configuration (SMTP)

### `SMTP_SERVER`
**Value:** `smtp.example.com`  
**Description:** SMTP server hostname for sending emails (notifications, password resets, etc.).

### `SMTP_PORT`
**Value:** `587`  
**Description:** SMTP server port. Port 587 is the standard for SMTP submission with STARTTLS.

### `SMTP_LOGIN`
**Value:** `smtp@example.com`  
**Description:** Username for SMTP authentication.

### `SMTP_PASSWORD`
**Value:** `XXXXXXXX` (hidden for security)  
**Description:** Password for SMTP authentication.  
**⚠️ Security:** Keep this secret and never share it publicly.

### `SMTP_AUTH_METHOD`
**Value:** `plain`  
**Description:** SMTP authentication method.  
**Options:** `plain`, `login`, `cram_md5`

### `SMTP_OPENSSL_VERIFY_MODE`
**Value:** `none`  
**Description:** SSL certificate verification mode for SMTP connection.  
**Options:** `none`, `peer`, `client_once`, `fail_if_no_peer_cert`  
**⚠️ Security:** `none` disables certificate verification - consider using `peer` for production.

### `SMTP_FROM_ADDRESS`
**Value:** `Mastodon <notifications@example.com>`  
**Description:** The "From" address used in outgoing emails. Format: `Display Name <email@domain.com>`

## 📝 Configuration Notes

- **Generated:** 2022-11-16 17:14:55 UTC
- **Docker Setup:** This configuration is optimized for Docker Compose deployment
- **Environment:** Production environment configuration

## 🚀 Setup Status

- ✅ Database configuration tested and working
- ✅ Redis configuration tested and working
- ⚠️ SMTP configuration not tested (test email skipped)
- ✅ Database schema loaded successfully

## 🔧 Maintenance

To regenerate this configuration:
```bash
docker-compose run web bundle exec rake mastodon:setup
```

To test email configuration:
```bash
docker-compose run web bundle exec rails console
# In Rails console:
# ActionMailer::Base.mail(from: 'test@example.com', to: 'admin@example.com', subject: 'Test', body: 'Test email').deliver_now
```

## 🛡️ Security Recommendations

1. **Change default values:** Replace `example.com` with your actual domain
2. **Secure SMTP:** Use `peer` for `SMTP_OPENSSL_VERIFY_MODE` in production
3. **Environment secrets:** Never commit actual secret keys to version control
4. **Database security:** Consider using a password for PostgreSQL in production
5. **Redis security:** Enable Redis authentication for production deployments

## 📚 Additional Resources

- [Mastodon Documentation](https://docs.joinmastodon.org/)
- [Environment Variables Reference](https://docs.joinmastodon.org/admin/config/)
- [Docker Deployment Guide](https://docs.joinmastodon.org/admin/install/)
