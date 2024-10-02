<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;

class CreatePackageStructure extends Command
{
    protected $signature = 'make:package {name} {--vendor=} {--package=}';
    protected $description = 'Create a new package structure with model, migration, seeder, and controller';

    public function handle()
    {
        $name = $this->argument('name');
        $vendor = $this->option('vendor');
        $package = $this->option('package');

        if (!$vendor || !$package) {
            $this->error('Both vendor and package options are required.');
            return;
        }

        // Mantener los nombres tal cual sin pasarlos a StudlyCase
        $paths = [
            "packages/{$vendor}/{$package}/src/Models/",
            "packages/{$vendor}/{$package}/src/Migrations/",
            "packages/{$vendor}/{$package}/src/Controllers/",
            "packages/{$vendor}/{$package}/src/Seeders/",
        ];

        foreach ($paths as $path) {
            if (!File::exists($path)) {
                File::makeDirectory($path, 0755, true);
                $this->info("Created directory: {$path}");
            }
        }

        // Crear modelo con migración
        $this->call('make:model', ['name' => $name, '--migration' => true]);

        // Crear Seeder
        $this->call('make:seeder', ['name' => "{$name}Seeder"]);

        // Crear Controller
        $this->call('make:controller', ['name' => "{$name}Controller"]);

        // Mover Model al paquete
        File::move(app_path("Models/{$name}.php"), base_path("packages/{$vendor}/{$package}/src/Models/{$name}.php"));
        $this->info("Moved Model to packages/{$vendor}/{$package}/src/Models/");

        // Mover Seeder al paquete
        File::move(database_path("seeders/{$name}Seeder.php"), base_path("packages/{$vendor}/{$package}/src/Seeders/{$name}Seeder.php"));
        $this->info("Moved Seeder to packages/{$vendor}/{$package}/src/Seeders/");

        // Mover Controller al paquete
        File::move(app_path("Http/Controllers/{$name}Controller.php"), base_path("packages/{$vendor}/{$package}/src/Controllers/{$name}Controller.php"));
        $this->info("Moved Controller to packages/{$vendor}/{$package}/src/Controllers/");

        // Mover Migration al paquete
        $migrationFile = $this->getLastMigrationFile($name);
        if ($migrationFile) {
            File::move(database_path("migrations/{$migrationFile}"), base_path("packages/{$vendor}/{$package}/src/Migrations/{$migrationFile}"));
            $this->info("Moved Migration to packages/{$vendor}/{$package}/src/Migrations/");
        } else {
            $this->error('Migration file not found.');
        }

        $this->info('Package structure created successfully.');
    }

    protected function getLastMigrationFile(string $modelName)
    {
        $pattern = '*_create_' . Str::snake(Str::pluralStudly($modelName)) . '_table.php';
        $files = glob(database_path('migrations/' . $pattern));

        return $files ? basename(end($files)) : null;
    }
}
