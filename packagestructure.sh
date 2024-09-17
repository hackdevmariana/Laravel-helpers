#!/bin/bash

# Verify that the package name has been passed
if [ -z "$1" ]; then
  echo "Please provide the package name."
  exit 1
fi

# Create a Laravel project
composer create-project --prefer-dist laravel/laravel "$1"
cd "$1"

# Create the necessary directories for the package
mkdir -p packages/vendor/"$1"/src
mkdir -p packages/vendor/"$1"/tests

# Convert the package name to CamelCase
CamelCase=$(echo "$1" | sed -r 's/(^|-)([a-z])/\U\2/g')

# Create the composer.json file for the package
cat <<EOL > packages/vendor/"$1"/composer.json
{
  "name": "vendor/$1",
  "description": "A description of your package",
  "autoload": {
    "psr-4": {
      "Vendor\\$CamelCase\\": "src/"
    }
  },
  "require": {
    "laravel/framework": "^8.0"
  },
  "extra": {
    "laravel": {
      "providers": [
        "Vendor\\$CamelCase\\PackageServiceProvider"
      ]
    }
  }
}
EOL

# Create the README.md file for documentation
cat <<EOL > packages/vendor/"$1"/README.md
# $CamelCase

Write here a description of your package.

## Installation

To install the package, add the following to your `composer.json`:

```
"require": { "vendor/$1": "*" }
```


Then run `composer update`.
EOL

# Confirmation of creation
echo "Package '$1' successfully created in 'packages/vendor/$1'."

