#!/bin/bash

set -e  # Stops the script if any command fails

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# Function to print usage
usage() {
    echo "Usage: $0 [options] projectname"
    echo
    echo "Options:"
    echo "  --help      Show this help and exit."
    echo "  --version   Displays the program version."
    echo ""
}

# Function to validate project name
validate_project_name() {
    if ! [[ $1 =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo -e "${RED}Error: Project name can only contain letters, numbers, and underscores.${NC}"
        exit 1
    fi
}

# Function to ensure commands exist
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Error: $1 command not found. Please install it.${NC}"
        exit 1
    fi
}

# Function to check and configure environment variables
configure_env() {
    cp ../../.env.example .env
    php artisan key:generate
    chmod -R 755 storage
    chmod -R 755 bootstrap/cache
}

# Function to handle database setup
setup_database() {
    db_motor=$(grep DB_CONNECTION .env | cut -d "=" -f 2)
    if [ "$db_motor" == "mysql" ]; then
        db_database=$(grep DB_DATABASE .env | cut -d "=" -f 2)
        db_username=$(grep DB_USERNAME .env | cut -d "=" -f 2)
        db_password=$(grep DB_PASSWORD .env | cut -d "=" -f 2)

        echo -e "${GREEN}Dropping existing database (if exists)${NC}"
        mysql -u"$db_username" -p"$db_password" -e "DROP DATABASE IF EXISTS $db_database;" || { echo "${RED}Error dropping database.${NC}"; exit 1; }
    fi
}

# Function to install Laravel project
install_laravel() {
    echo -e "${GREEN}Installing Laravel...${NC}"
    composer create-project laravel/laravel "${PROJECT_NAME}_back" || { echo "${RED}Error creating Laravel project${NC}"; exit 1; }
    cd "${PROJECT_NAME}_back" || { echo "${RED}Error changing to project directory${NC}"; exit 1; }
    configure_env
    setup_database
}

# Function to install Nuxt project
install_nuxt() {
    echo -e "${GREEN}Installing Nuxt...${NC}"
    npx nuxi init "${PROJECT_NAME}_front" || { echo "${RED}Error creating Nuxt project${NC}"; exit 1; }
    cd "${PROJECT_NAME}_front"
    npm install || { echo "${RED}Error installing Nuxt${NC}"; exit 1; }
}

# Main logic
if [ -z "$1" ]; then
    echo -e "${RED}Error: No project name specified.${NC}"
    usage
    exit 1
fi

case "$1" in
    --help)
        usage
        exit 0
        ;;
    --version)
        echo "$0 0.0.3"
        exit 0
        ;;
    *)
        PROJECT_NAME="$1"
        validate_project_name "$PROJECT_NAME"
        ;;
esac

# Ensure required commands exist
check_command composer
check_command mysql
check_command npm

# Confirm before deleting project directory
if [ -d "$PROJECT_NAME" ]; then
    read -p "Project directory already exists. Do you want to delete it? [y/N]: " confirm
    if [ "$confirm" != "y" ]; then
        echo "Aborted."
        exit 1
    fi
    rm -rf "$PROJECT_NAME"
fi

# Create project directory
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Install Laravel and configure
install_laravel

# Install Voyager
echo -e "${GREEN}Installing Voyager...${NC}"
composer require tcg/voyager || { echo "${RED}Error installing Voyager${NC}"; exit 1; }
php artisan voyager:install || { echo "${RED}Error installing Voyager components${NC}"; exit 1; }
php artisan migrate || { echo "${RED}Error in the Voyager migrate${NC}"; exit 1; }
echo "Enter the email of the administrator user:"
read adminmail
php artisan voyager:admin $adminmail --create || { echo "${RED}Error creating admin user${NC}"; exit 1; }

# Final configurations
php artisan config:cache
php artisan route:cache
php artisan view:clear

cd ..

# Install Nuxt
install_nuxt

# Final message
echo -e "${GREEN}Laravel and Nuxt have been successfully installed.${NC}"
echo "You can start backend development in ${PROJECT_NAME}_back and frontend development in ${PROJECT_NAME}_front."
