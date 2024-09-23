#!/bin/bash

capitalize() {
    echo "$1" | tr '[:lower:]' '[:upper:]' | sed 's/^\(.\)/\U\1/'
}

# Comprobar el número de parámetros
if [ $# -eq 0 ]; then
    echo "A package name is required to create."
    exit 1
elif [ $# -eq 1 ]; then
    # Comprobar si el parámetro contiene un punto
    if [[ $1 == *.* ]]; then
        package="${1%%.*}"
        vendor="${1##*.}"
    else
        echo "The parameter must contain a dot to split into vendor and package."
        exit 1
    fi
elif [ $# -eq 2 ]; then
    vendor=$(echo $1 | tr '[:upper:]' '[:lower:]')
    package=$(echo $2 | tr '[:upper:]' '[:lower:]')
else
    echo "Too many parameters provided."
    exit 1
fi

Vendor=$(capitalize "$vendor")
Package=$(capitalize "$package")

[ -d packages ] || mkdir packages
[ -d packages/$vendor ] || mkdir packages/$vendor
[ -d packages/$vendor/$package ] || mkdir packages/$vendor/$package
[ -d packages/$vendor/$package/src ] || mkdir packages/$vendor/$package/src
[ -d packages/$vendor/$package/src/Models ] || mkdir packages/$vendor/$package/src/Models
[ -d packages/$vendor/$package/src/Migrations ] || mkdir packages/$vendor/$package/src/Migrations
[ -d packages/$vendor/$package/src/Routes ] || mkdir packages/$vendor/$package/src/Routes
[ -d packages/$vendor/$package/src/Providers ] || mkdir packages/$vendor/$package/src/Providers

echo "Briefly describe your project"
read description

# Crear composer.json del paquete
cat <<EOL > packages/$vendor/$package/composer.json
{
    "name": "$vendor/$package",
    "description": "$description",
    "autoload": {
        "psr-4": {
            "$Vendor\\\\$Package\\\\": "src/"
        }
    },
    "extra": {
        "laravel": {
            "providers": [
                "$Vendor\\\\$Package\\\\Providers\\\\${Package}ServiceProvider"
            ]
        }
    }
}
EOL

# Crear el ServiceProvider
cat <<EOL > packages/$vendor/$package/src/Providers/${Package}ServiceProvider.php
<?php

namespace $Vendor\\$Package\\Providers;

use Illuminate\Support\ServiceProvider;

class ${Package}ServiceProvider extends ServiceProvider
{
    public function register()
    {
        // Registrar el paquete
    }

    public function boot()
    {
        // Cargar vistas, rutas, migraciones
        \$this->loadRoutesFrom(__DIR__.'/../Routes/web.php');
        \$this->loadMigrationsFrom(__DIR__.'/../Migrations');
    }
}
EOL

# Modificar composer.json del proyecto principal
sed -i "/\"psr-4\": {/a \ \ \ \ \"$Vendor\\\\\\\\$Package\\\\\\\\\": \"packages/$vendor/$package/src/\"," composer.json

# Crear un archivo de rutas vacío para evitar errores
touch packages/$vendor/$package/src/Routes/web.php

# Actualizar autoload
composer dump-autoload

echo "Package $vendor/$package created successfully!"
