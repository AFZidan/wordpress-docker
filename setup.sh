#!/bin/bash

# WordPress Docker Setup Script
# This script downloads WordPress, optionally installs WooCommerce plugin, and manages Docker containers

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WORDPRESS_DIR="./wordpress"
TEMP_DIR="./temp_download"
WORDPRESS_VERSION=${WORDPRESS_VERSION:-"latest"}

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if required commands exist
check_dependencies() {
    print_status "Checking dependencies..."

    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed."
        exit 1
    fi

    if ! command -v unzip &> /dev/null; then
        print_error "unzip is required but not installed."
        exit 1
    fi

    print_success "All dependencies are available."
}

# Function to check if Docker and Docker Compose are available
check_docker() {
    print_status "Checking Docker and Docker Compose..."

    if ! command -v docker &> /dev/null; then
        print_error "Docker is required but not installed."
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
        print_error "Docker Compose is required but not installed."
        exit 1
    fi

    print_success "Docker and Docker Compose are available."
}

# Function to clean up temporary files
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        print_status "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

# Function to download and extract WordPress
download_wordpress() {
    print_status "Downloading WordPress ${WORDPRESS_VERSION}..."

    # Create temporary directory
    mkdir -p "$TEMP_DIR"

    # Download WordPress
    if [ "$WORDPRESS_VERSION" = "latest" ]; then
        DOWNLOAD_URL="https://wordpress.org/latest.zip"
    else
        DOWNLOAD_URL="https://wordpress.org/wordpress-${WORDPRESS_VERSION}.zip"
    fi

    print_status "Downloading from: $DOWNLOAD_URL"
    curl -L -o "$TEMP_DIR/wordpress.zip" "$DOWNLOAD_URL"

    if [ $? -ne 0 ]; then
        print_error "Failed to download WordPress"
        cleanup
        exit 1
    fi

    print_success "WordPress downloaded successfully."
}

# Function to extract WordPress
extract_wordpress() {
    print_status "Extracting WordPress..."

    # Create wordpress directory if it doesn't exist
    mkdir -p "$WORDPRESS_DIR"

    # Extract WordPress
    unzip -q "$TEMP_DIR/wordpress.zip" -d "$TEMP_DIR"

    # Move WordPress files to the correct location
    cp -r "$TEMP_DIR/wordpress/"* "$WORDPRESS_DIR/"

    print_success "WordPress extracted to $WORDPRESS_DIR"
}

# Function to download WooCommerce plugin
download_woocommerce() {
    print_status "Downloading WooCommerce plugin..."

    # Create plugins directory if it doesn't exist
    mkdir -p "$WORDPRESS_DIR/wp-content/plugins"

    # Download WooCommerce
    WOOCOMMERCE_URL="https://downloads.wordpress.org/plugin/woocommerce.latest-stable.zip"
    curl -L -o "$TEMP_DIR/woocommerce.zip" "$WOOCOMMERCE_URL"

    if [ $? -ne 0 ]; then
        print_error "Failed to download WooCommerce"
        return 1
    fi

    # Extract WooCommerce
    unzip -q "$TEMP_DIR/woocommerce.zip" -d "$WORDPRESS_DIR/wp-content/plugins/"

    print_success "WooCommerce plugin installed successfully."
}

# Function to set proper permissions
set_permissions() {
    print_status "Setting proper permissions..."

    # Set permissions for WordPress files
    find "$WORDPRESS_DIR" -type d -exec chmod 755 {} \;
    find "$WORDPRESS_DIR" -type f -exec chmod 644 {} \;

    # Make wp-config.php writable if it exists
    if [ -f "$WORDPRESS_DIR/wp-config.php" ]; then
        chmod 666 "$WORDPRESS_DIR/wp-config.php"
    fi

    print_success "Permissions set successfully."
}

# Function to create wp-config.php template
create_wp_config() {
    if [ ! -f "$WORDPRESS_DIR/wp-config.php" ] && [ -f "$WORDPRESS_DIR/wp-config-sample.php" ]; then
        print_status "Creating wp-config.php from template..."

        cp "$WORDPRESS_DIR/wp-config-sample.php" "$WORDPRESS_DIR/wp-config.php"

        # Update database configuration to match docker-compose.yml
        sed -i.bak "s/database_name_here/wordpress/g" "$WORDPRESS_DIR/wp-config.php"
        sed -i.bak "s/username_here/wpuser/g" "$WORDPRESS_DIR/wp-config.php"
        sed -i.bak "s/password_here/wppassword/g" "$WORDPRESS_DIR/wp-config.php"
        sed -i.bak "s/localhost/db/g" "$WORDPRESS_DIR/wp-config.php"

        # Remove backup file
        rm -f "$WORDPRESS_DIR/wp-config.php.bak"

        print_success "wp-config.php created with database settings."
        print_warning "Remember to update the authentication keys and salts in wp-config.php"
    fi
}

# Function to stop and remove existing containers
docker_down() {
    print_status "Stopping existing containers..."
    if command -v docker-compose &> /dev/null; then
        docker-compose down --remove-orphans
    else
        docker compose down --remove-orphans
    fi
    print_success "Containers stopped."
}

# Function to build and start containers
docker_up() {
    print_status "Building and starting Docker containers..."
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d --build
    else
        docker compose up -d --build
    fi

    # Wait a moment for containers to start
    sleep 3

    # Check if containers are running
    if command -v docker-compose &> /dev/null; then
        if docker-compose ps | grep -q "Up"; then
            print_success "Docker containers are running successfully."
        else
            print_error "Some containers failed to start. Check logs with: docker-compose logs"
            return 1
        fi
    else
        if docker compose ps | grep -q "running"; then
            print_success "Docker containers are running successfully."
        else
            print_error "Some containers failed to start. Check logs with: docker compose logs"
            return 1
        fi
    fi
}

# Function to display container status
show_status() {
    print_status "Container status:"
    if command -v docker-compose &> /dev/null; then
        docker-compose ps
    else
        docker compose ps
    fi
}

# Function to open WordPress in browser (macOS only)
open_wordpress() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Opening WordPress in your default browser..."
        sleep 2
        open "http://localhost:8000"
    fi
}

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -w, --wordpress-version VERSION  Specify WordPress version (default: latest)"
    echo "  -c, --woocommerce               Install WooCommerce plugin"
    echo "  -f, --force                     Force reinstall (remove existing files)"
    echo "  -d, --docker-only               Only manage Docker containers (skip WordPress download)"
    echo "  -s, --start                     Start Docker containers after setup"
    echo "  -r, --restart                   Restart Docker containers"
    echo "  --down                          Stop Docker containers"
    echo "  --status                        Show container status"
    echo "  --open                          Open WordPress in browser (macOS only)"
    echo "  --woocommerce-only              Install WooCommerce plugin only (skip WordPress download)"
    echo "  -h, --help                      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                              Download latest WordPress"
    echo "  $0 --woocommerce --start        Download WordPress with WooCommerce and start containers"
    echo "  $0 -w 6.1 -c -s                Download WordPress 6.1 with WooCommerce and start containers"
    echo "  $0 --docker-only --start        Only start Docker containers"
    echo "  $0 --woocommerce-only           Install WooCommerce to existing WordPress"
    echo "  $0 --restart                    Restart Docker containers"
    echo "  $0 --down                       Stop all containers"
    echo "  $0 --force --start              Force reinstall WordPress and start containers"
}

# Main script logic
main() {
    local install_woocommerce=false
    local force_install=false
    local docker_only=false
    local start_containers=false
    local restart_containers=false
    local stop_containers=false
    local show_container_status=false
    local open_browser=false
    local woocommerce_only=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -w|--wordpress-version)
                WORDPRESS_VERSION="$2"
                shift 2
                ;;
            -c|--woocommerce)
                install_woocommerce=true
                shift
                ;;
            -f|--force)
                force_install=true
                shift
                ;;
            -d|--docker-only)
                docker_only=true
                shift
                ;;
            -s|--start)
                start_containers=true
                shift
                ;;
            -r|--restart)
                restart_containers=true
                shift
                ;;
            --down)
                stop_containers=true
                shift
                ;;
            --status)
                show_container_status=true
                shift
                ;;
            --open)
                open_browser=true
                shift
                ;;
            --woocommerce-only)
                woocommerce_only=true
                install_woocommerce=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    echo "WordPress Docker Setup Script"
    echo "=============================="

    # Handle Docker-only operations
    if [ "$stop_containers" = true ]; then
        check_docker
        docker_down
        exit 0
    fi

    if [ "$show_container_status" = true ]; then
        check_docker
        show_status
        exit 0
    fi

    if [ "$open_browser" = true ]; then
        open_wordpress
        exit 0
    fi

    if [ "$restart_containers" = true ]; then
        check_docker
        docker_down
        docker_up
        echo ""
        print_success "Containers restarted successfully!"
        echo "Visit: http://localhost:8000"
        exit 0
    fi

    # Handle WooCommerce-only installation
    if [ "$woocommerce_only" = true ]; then
        check_dependencies

        # Check if WordPress directory exists
        if [ ! -d "$WORDPRESS_DIR" ] || [ ! "$(ls -A $WORDPRESS_DIR)" ]; then
            print_error "WordPress directory does not exist or is empty."
            print_error "Please install WordPress first or use --woocommerce with full setup."
            exit 1
        fi

        # Check if plugins directory exists
        if [ ! -d "$WORDPRESS_DIR/wp-content/plugins" ]; then
            print_error "WordPress plugins directory not found."
            print_error "Please ensure WordPress is properly installed."
            exit 1
        fi

        # Set up cleanup trap
        trap cleanup EXIT

        # Create temporary directory
        mkdir -p "$TEMP_DIR"

        # Download and install WooCommerce
        download_woocommerce

        # Clean up
        cleanup

        print_success "WooCommerce installation completed!"
        echo "Don't forget to activate WooCommerce plugin in WordPress admin"
        exit 0
    fi

    # Check dependencies for WordPress operations
    if [ "$docker_only" = false ]; then
        check_dependencies
    fi

    check_docker

    # WordPress setup (unless docker-only)
    if [ "$docker_only" = false ]; then
        # Check if WordPress already exists
        if [ -d "$WORDPRESS_DIR" ] && [ "$(ls -A $WORDPRESS_DIR)" ]; then
            if [ "$force_install" = true ]; then
                print_warning "Removing existing WordPress installation..."
                rm -rf "$WORDPRESS_DIR"
            else
                print_warning "WordPress directory already exists and is not empty."
                echo "Use --force to reinstall or remove the directory manually."
                echo "Or use --docker-only to skip WordPress download."
                echo "Or use --woocommerce-only to just install WooCommerce."
                exit 1
            fi
        fi

        # Set up cleanup trap
        trap cleanup EXIT

        # Download and extract WordPress
        download_wordpress
        extract_wordpress

        # Download WooCommerce if requested
        if [ "$install_woocommerce" = true ]; then
            download_woocommerce
        fi

        # Create wp-config.php
        create_wp_config

        # Set permissions
        set_permissions

        # Clean up
        cleanup

        print_success "WordPress setup completed!"
    fi

    # Start containers if requested
    if [ "$start_containers" = true ]; then
        echo ""
        docker_up
    fi

    echo ""
    echo "Available commands:"
    if [ "$start_containers" = false ] && [ "$docker_only" = false ]; then
        echo "• Start containers: ./setup.sh --start"
        echo "• Start with setup:  ./setup.sh --woocommerce --start"
    fi
    echo "• Stop containers:   ./setup.sh --down"
    echo "• Restart containers: ./setup.sh --restart"
    echo "• Show status:       ./setup.sh --status"
    echo "• Open in browser:   ./setup.sh --open"
    echo "• Install WooCommerce: ./setup.sh --woocommerce-only"
    echo ""

    if [ "$start_containers" = true ] || [ "$docker_only" = true ]; then
        echo "WordPress is now running at: http://localhost:8000"
        if [ "$install_woocommerce" = true ]; then
            echo "Don't forget to activate WooCommerce plugin in WordPress admin"
        fi
    else
        echo "Next steps:"
        echo "1. Run: ./setup.sh --start"
        echo "2. Visit: http://localhost:8000"
        echo "3. Complete the WordPress installation"
        if [ "$install_woocommerce" = true ]; then
            echo "4. Activate WooCommerce plugin in WordPress admin"
        fi
    fi
}

# Run main function with all arguments
main "$@"
