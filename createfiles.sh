#!/bin/bash

# Create model, controller and seeder (Laravel) and Filament resource
php artisan make:model $1 -m
php artisan make:controller Api/$1Controller
php artisan make:seeder $1Seeder
php artisan make:filament-resource $1

# Get the latest created migration
last_migration=$(ls -t database/migrations/ | head -n 1)

# Add the line in the migration
sed -i "/\$table->timestamps();/i \        \$table->string('name');" database/migrations/$last_migration

# Add the fillable property to the model
sed -i "/use HasFactory;/i \ \tprotected \$fillable = ['name'];" app/Models/$1.php

sed -i "/use App\\\Http\\\Controllers\\\Controller;/i \use App\\\Models\\\\${1};" app/Http/Controllers/Api/${1}Controller.php
sed -i "/use App\\\Http\\\Controllers\\\Controller;/i \use Illuminate\\\Http\\\JsonResponse;" app/Http/Controllers/Api/${1}Controller.php

# Add the index method in the controller
sed -i "/{/a \\
public function index(): JsonResponse\\n    {\\n        \$random$1 = $1::inRandomOrder()->first()->name;\\n        return response()->json(['name' => \$random$1]);\\n    }" app/Http/Controllers/Api/${1}Controller.php

# Add the field in the Filament resource
sed -i "/->schema(\[/a \\
Forms\\\Components\\\TextInput::make('name')\\n                    ->required()\\n                    ->label('${1} name')\\n                    ->maxLength(255)," app/Filament/Resources/${1}Resource.php

# Add the column in the Filament resource
sed -i "/->columns(\[/a \\
Tables\\\Columns\\\TextColumn::make('name')\\n                    ->label('${1} name')\\n                    ->sortable()\\n                    ->searchable()," app/Filament/Resources/${1}Resource.php
