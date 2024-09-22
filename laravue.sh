#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: No project name specified."
  echo ""
  echo "More information: --help"
  echo ""
  exit 1
fi

if [ "$1" == "--help" ]; then
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --help      Show this help and exit."
    echo "  --version   Displays the program version."
    echo "  projectname Name of the project to create."
    echo ""
    exit 0
fi

if [ "$1" == "--version" ]; then
    echo "$0 0.0.1"
    exit 0
fi


PROJECT_NAME="$1"

# Delete project directory if exists
if [ -d "$PROJECT_NAME" ]; then
    rm -rf "$PROJECT_NAME"
fi

mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create Laravel project
composer create-project laravel/laravel "$PROJECT_NAME"_back || { echo "Error creating Laravel project"; exit 1; }

cd "$PROJECT_NAME"_back || { echo "Error changing to project directory"; exit 1; }

# Install Backpack
composer require backpack/crud || { echo "Error creating Backpack dashboard"; exit 1; }

cd .. 

# Install Nuxt

npx nuxi init "$PROJECT_NAME"_front || { echo "Error creating Nuxt project"; exit 1; }
cd "$PROJECT_NAME"_front
npm install || { echo "Error installing Nuxt"; exit 1; }

cd .. 

echo "Laravel and Nuxt have been successfully installed."
echo ""
echo "You can start backend development in the directory ${PROJECT_NAME}_back."
echo "And frontend development in the directory ${PROJECT_NAME}_front."
