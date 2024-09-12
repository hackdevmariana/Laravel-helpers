#!/bin/bash

php artisan migrate
php artisan db:seed --class=$1Seeder
