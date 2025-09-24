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
**How to generate:**
- **Rails command:** `rails secret` or `bundle exec rails secret`
- **OpenSSL:** `openssl rand -hex 64`
- **Ruby:** `ruby -e "require 'securerandom'; puts SecureRandom.hex(64)"`
- **Online generator:** Use a secure random string generator (128 characters recommended)
- **Mastodon setup:** Automatically generated during `rake mastodon:setup`

### `OTP_SECRET`
**Value:** `XXXXXXXX` (hidden for security)  
**Description:** Secret key used for generating one-time passwords (2FA).  
**⚠️ Security:** Keep this secret and never share it publicly.
**How to generate:**
- **Python:** `python3 -c "import secrets, base64; print(base64.b32encode(secrets.token_bytes(20)).decode().rstrip('='))"`
- **Ruby:** `ruby -e "require 'securerandom'; puts SecureRandom.base32(32)"`
- **Node.js:** `node -e "console.log(require('crypto').randomBytes(20).toString('base64').replace(/[+/=]/g, '').substring(0,32))"`
- **OpenSSL + Python:** `openssl rand -hex 20 | python3 -c "import sys, base64; print(base64.b32encode(bytes.fromhex(sys.stdin.read().strip())).decode().rstrip('='))"`
- **Manual:** Any 32-character base32 string using A-Z and 2-7 (no 0, 1, 8, 9)
- **Mastodon setup:** Automatically generated during `rake mastodon:setup`

## 🔔 Web Push Notifications (VAPID)

### `VAPID_PRIVATE_KEY` & `VAPID_PUBLIC_KEY`
**Values:** `XXXXXXXX` (hidden for security)  
**Description:** VAPID keys used for web push notifications. These allow your Mastodon instance to send push notifications to users' browsers.  
**Note:** Generated as a pair - both are required for push notifications to work.
**How to generate:**
- **Node.js web-push:** `npx web-push generate-vapid-keys` (outputs both keys directly)
- **Ruby gem:** `gem install webpush` then `ruby -e "require 'webpush'; keys = Webpush.generate_key; puts keys"`
- **Mastodon setup:** Automatically generated during `rake mastodon:setup`

**Note:** The keys are used directly as environment variable values, not as file paths. The OpenSSL method creates `.pem` files which would need additional processing to extract the key values for use in environment variables.

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

**Security considerations:**
- **Development/Testing:** Empty password is acceptable when Redis is only accessible within Docker network
- **Production:** Should set a strong password to prevent unauthorized access
- **Docker isolation:** In this setup, Redis is only accessible to other containers in the same Docker network
- **Network exposure:** If Redis port (6379) is exposed externally, authentication becomes critical

**How to secure for production:**
- Set `REDIS_PASSWORD=your_secure_password` in environment
- Configure Redis with `requirepass your_secure_password` in redis.conf
- Use Redis ACLs for more granular access control (Redis 6+)

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
**Where to get this:**
- **Email provider:** Provided by your SMTP service (Gmail, Outlook, SendGrid, etc.)
- **Gmail:** Use App Password (not your regular Gmail password) - enable 2FA first, then generate app-specific password
- **Outlook/Hotmail:** Use App Password from Microsoft Account security settings
- **Custom SMTP:** Contact your email hosting provider or system administrator
- **Third-party services:** API key or password from services like SendGrid, Mailgun, Amazon SES
- **Self-hosted:** Password you set when configuring your mail server (Postfix, etc.)

### `SMTP_AUTH_METHOD`
**Value:** `plain`  
**Description:** SMTP authentication method.  
**Options:** `plain`, `login`, `cram_md5`
**Why `plain` over `login` or `cram_md5`?**
- **`plain`**: Most widely supported by SMTP servers. Sends credentials in base64 encoding (not encrypted, but obfuscated). Safe when used with TLS/SSL encryption (port 587 with STARTTLS).
- **`login`**: Similar security to `plain` but uses a different authentication flow. Less universally supported than `plain`.
- **`cram_md5`**: More secure as it uses MD5 hashing and challenge-response authentication, but many modern SMTP providers (Gmail, Outlook, etc.) don't support it or have deprecated it in favor of OAuth2.

**Recommendation:** `plain` is the safest choice for compatibility while maintaining security when combined with TLS encryption (which is enabled by default on port 587).

### `SMTP_OPENSSL_VERIFY_MODE`
**Value:** `none`  
**Description:** SSL certificate verification mode for SMTP connection.  
**Options:** `none`, `peer`, `client_once`, `fail_if_no_peer_cert`  
**Why `none` and what do the other options mean?**
- **`none`**: Disables SSL certificate verification entirely. Connection is encrypted but server identity is not verified. Used here for initial setup/testing to avoid certificate issues.
- **`peer`**: Verifies the server's SSL certificate against trusted Certificate Authorities. Most secure option for production - ensures you're connecting to the legitimate SMTP server.
- **`client_once`**: Verifies the certificate only once during the initial handshake, then trusts subsequent connections. Less secure than `peer`.
- **`fail_if_no_peer_cert`**: Requires a peer certificate to be present and will fail if none is provided. Strictest verification mode.

**Recommendation:** Use `peer` for production environments to prevent man-in-the-middle attacks. `none` is acceptable for development/testing or when dealing with self-signed certificates.

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
