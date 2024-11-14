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


        $paths = [
            "packages/{$vendor}/{$package}/src/Models/",
            "packages/{$vendor}/{$package}/src/Migrations/",
            "packages/{$vendor}/{$package}/src/Controllers/Api/",
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
        $this->info("Moved Controller to packages/{$vendor}/{$package}/src/Controllers/Api");

        // Mover Migration al paquete
        $migrationFile = $this->getLastMigrationFile($name);
        if ($migrationFile) {
            File::move(database_path("migrations/{$migrationFile}"), base_path("packages/{$vendor}/{$package}/src/Migrations/{$migrationFile}"));
            $this->info("Moved Migration to packages/{$vendor}/{$package}/src/Migrations/");
        } else {
            $this->error('Migration file not found.');
        }

        // Crear ServiceProvider

        $providerNamespace = Str::studly($vendor) . '\\' . Str::studly($package);


        $providerContent = "<?php\n\nnamespace {$providerNamespace};\n\nuse Illuminate\Support\ServiceProvider;\n\nclass " . Str::studly($package) . "ServiceProvider extends ServiceProvider\n{\n\tpublic function register()\n\t{\n\t\t// Register package services\n\t}\n\n\tpublic function boot()\n\t{\n\t\t// Register package routes, migrations, etc.\n\t\tif (\$this->app->runningInConsole()) {\n\t\t\t\$this->loadMigrationsFrom(__DIR__.'/Migrations');\n\t\t}\n\t}\n}\n";

        File::put(base_path("packages/{$vendor}/{$package}/src/{$package}ServiceProvider.php"), $providerContent);
        $this->info("Created ServiceProvider for {$vendor}/{$package}");

        $composerFile = base_path('composer.json');
        $composerData = json_decode(file_get_contents($composerFile), true);

        $composerData['autoload']['psr-4']["{$providerNamespace}\\"] = "packages/{$vendor}/{$package}/src/";

        file_put_contents($composerFile, json_encode($composerData, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));



        $this->info('Package structure created successfully.');
    }

    protected function getLastMigrationFile(string $modelName)
    {
        $pattern = '*_create_' . Str::snake(Str::pluralStudly($modelName)) . '_table.php';
        $files = glob(database_path('migrations/' . $pattern));

        return $files ? basename(end($files)) : null;
    }
}
