### Run Wordpress with Docker

This repository contains a Docker setup to run a WordPress instance with automatic WordPress and WooCommerce installation capabilities and integrated Docker management.

## Prerequisites

- Docker installed on your machine
- Docker Compose installed (if not included with your Docker installation)
- curl and unzip utilities (usually pre-installed on macOS and Linux)

## Quick Start

### Complete Setup (WordPress + Docker)

```bash
# Download WordPress and start containers
./setup.sh --start

# Download WordPress with WooCommerce and start containers
./setup.sh --woocommerce --start

# Download specific WordPress version with WooCommerce and start containers
./setup.sh --wordpress-version 6.4 --woocommerce --start
```

### Docker Management Only

```bash
# Start containers (existing WordPress installation)
./setup.sh --docker-only --start

# Restart containers
./setup.sh --restart

# Stop containers
./setup.sh --down

# Show container status
./setup.sh --status

# Open WordPress in browser (macOS)
./setup.sh --open
```

## Setup Script Options

The `setup.sh` script provides comprehensive WordPress and Docker management:

### WordPress Options:
- `-w, --wordpress-version VERSION`: Specify WordPress version (default: latest)
- `-c, --woocommerce`: Install WooCommerce plugin
- `-f, --force`: Force reinstall (remove existing files)

### Docker Options:
- `-d, --docker-only`: Only manage Docker containers (skip WordPress download)
- `-s, --start`: Start Docker containers after setup
- `-r, --restart`: Restart Docker containers
- `--down`: Stop Docker containers
- `--status`: Show container status
- `--open`: Open WordPress in browser (macOS only)

### Examples:

```bash
# Complete WordPress setup with containers
./setup.sh --woocommerce --start

# Just download WordPress (no Docker commands)
./setup.sh --woocommerce

# Start existing setup
./setup.sh --docker-only --start

# Quick restart
./setup.sh --restart

# Stop everything
./setup.sh --down

# Check what's running
./setup.sh --status
```

## What the Setup Script Does

### WordPress Setup:
1. **Downloads WordPress**: Fetches the specified WordPress version from wordpress.org
2. **Extracts Files**: Extracts WordPress to the `./wordpress` directory
3. **WooCommerce Installation**: Optionally downloads and installs WooCommerce plugin
4. **Configuration**: Creates `wp-config.php` with database settings matching docker-compose.yml
5. **Permissions**: Sets appropriate file permissions
6. **Cleanup**: Removes temporary files

### Docker Management:
1. **Container Health Checks**: Verifies Docker and Docker Compose are available
2. **Smart Container Management**: Handles both `docker-compose` and `docker compose` commands
3. **Status Monitoring**: Shows container status and health
4. **Browser Integration**: Opens WordPress in default browser (macOS)
5. **Graceful Shutdown**: Properly stops containers with orphan cleanup

## Docker Services

This setup includes:

- **WordPress**: PHP-FPM container with WordPress files
- **Nginx**: Web server on port 8000
- **MySQL**: Database server (mysql:5.7)
- **phpMyAdmin**: Database management interface

## Database Configuration

The setup script automatically configures WordPress with these database settings:
- Database: `wordpress`
- Username: `wpuser`
- Password: `wppassword`
- Host: `db` (Docker service name)

## Managing the Environment

```bash
# Start containers
docker-compose up -d

# Stop containers
docker-compose down

# View logs
docker-compose logs wordpress

# Rebuild and restart
docker-compose up -d --build
```

## File Structure

```
.
├── docker-compose.yaml    # Docker services configuration
├── Dockerfile            # WordPress container definition
├── setup-wordpress.sh    # WordPress/WooCommerce setup script
├── php.ini              # PHP configuration
├── nginx/               # Nginx configuration
│   └── conf.d/
├── php-logs/            # PHP error logs
└── wordpress/           # WordPress files (created by script)
    └── wp-content/
        └── plugins/     # WooCommerce installed here
```
