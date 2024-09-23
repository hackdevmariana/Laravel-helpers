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

# Function to check for trait in User model
check_user_model() {
    if ! grep -q "use Spatie\\Permission\\Traits\\HasRoles;" app/Models/User.php; then
        rm app/Models/User.php
        cat <<EOL > app/Models/User.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasRoles;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected \$fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected \$hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected \$casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];
}

EOL
    fi
}

# Function to check migrations
check_migrations() {
    if ! php artisan migrate:status | grep -q 'roles'; then
        echo "The roles table does not exist. Attempting to run the migration again."
        php artisan migrate --path=vendor/spatie/laravel-permission/database/migrations || {
            echo "${RED}Error running the migration for roles table. Please check your migrations.${NC}";
            exit 1;
        }
    fi
}

# Function to ensure commands exist
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "${RED}Error: $1 command not found. Please install it.${NC}"
        exit 1
    fi
}

# Function to check and configure environment variables
configure_env() {
    cp ../../.env.example .env
    chmod u+w .env
    php artisan key:generate
    chmod -R 775 storage
    chmod -R 775 bootstrap/cache
}

# Function to handle database setup
setup_database() {
    db_motor=$(grep DB_CONNECTION .env | cut -d "=" -f 2)
    if [ "$db_motor" == "mysql" ]; then
        db_database=$(grep DB_DATABASE .env | cut -d "=" -f 2)
        db_username=$(grep DB_USERNAME .env | cut -d "=" -f 2)
        db_password=$(grep DB_PASSWORD .env | cut -d "=" -f 2)

        mysql -u"$db_username" -p"$db_password" -e "DROP DATABASE IF EXISTS $db_database;" || { echo "${RED}Error dropping database.${NC}"; exit 1; }
    fi
}

# Function to install Laravel project
install_laravel() {
    composer create-project laravel/laravel "${PROJECT_NAME}_back" || { echo "${RED}Error creating Laravel project${NC}"; exit 1; }
    cd "${PROJECT_NAME}_back" || { echo "${RED}Error changing to project directory${NC}"; exit 1; }
    configure_env
    setup_database
}

# Function to install Nuxt project
install_nuxt() {
    npx nuxi init "${PROJECT_NAME}_front" || { echo "${RED}Error creating Nuxt project${NC}"; exit 1; }
    cd "${PROJECT_NAME}_front"
    npm install || { echo "${RED}Error installing Nuxt${NC}"; exit 1; }
}

# Main logic
if [ -z "$1" ]; then
    echo "${RED}Error: No project name specified.${NC}"
    usage
    exit 1
fi

case "$1" in
    --help)
        usage
        exit 0
        ;;
    --version)
        echo "$0 0.0.2"
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

# Delete project directory if exists
[ -d "$PROJECT_NAME" ] && rm -rf "$PROJECT_NAME"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Install Laravel and configure
install_laravel

# Install Backpack
composer require backpack/crud || { echo "${RED}Error installing Backpack${NC}"; exit 1; }

# Middleware creation if necessary
if [ ! -f app/Http/Middleware/CheckIfAdmin.php ]; then
cat <<EOL > app/Http/Middleware/CheckIfAdmin.php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckIfAdmin
{
    public function handle(Request \$request, Closure \$next)
    {
        return \$next(\$request);
    }
}
EOL

sed -i "/protected \$routeMiddleware = \[/a \ \ \ \ 'admin' => \App\Http\Middleware\CheckIfAdmin::class," app/Http/Kernel.php
fi

# Install Spatie Laravel Permission
composer require spatie/laravel-permission
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
php artisan migrate || { echo "${RED}Error running migrations.${NC}"; exit 1; }

# Check User model and migrations
check_user_model
check_migrations

# Seeder creation
php artisan make:seeder AdminUserSeeder
read -p "Admin username: " username
read -p "Admin email: " email
read -s -p "Admin password: " password

cat <<EOL > database/seeders/AdminUserSeeder.php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Spatie\Permission\Models\Role;

class AdminUserSeeder extends Seeder
{
    public function run()
    {
        \$adminRole = Role::firstOrCreate(['name' => 'admin']);

        \$admin = User::create([
            'name' => '$username',
            'email' => '$email',
            'password' => bcrypt('$password'),
        ]);

        \$admin->assignRole(\$adminRole);
    }
}
EOL

# Final configurations and feedback
check_migrations
php artisan db:seed --class=AdminUserSeeder

php artisan config:cache
php artisan route:cache
php artisan view:clear

cd ..

# Install Nuxt
install_nuxt

# Final message
echo -e "${GREEN}Laravel and Nuxt have been successfully installed.${NC}"
echo "You can start backend development in ${PROJECT_NAME}_back and frontend development in ${PROJECT_NAME}_front."
