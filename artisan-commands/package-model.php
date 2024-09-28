<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Filesystem\Filesystem;

class MakePackageModel extends Command
{
    protected $signature = 'make:package-model {name} {--package=} {--vendor=works} {--migration}';
    protected $description = 'Create a model and migration in a specific package and vendor directory';

    public function handle()
    {
        $name = $this->argument('name');
        $package = $this->option('package') ?? 'webworks';
        $vendor = $this->option('vendor') ?? 'works'; // Parámetro vendor
        $createMigration = $this->option('migration');

        // Definir la ruta destino del modelo en el paquete
        $modelDestinationNamespace = "{$vendor}\\{$package}\\Models\\{$name}";
        $modelDestinationPath = "packages/{$vendor}/{$package}/src/Models/{$name}.php";

        // Crear el modelo directamente en la ruta del paquete
        Artisan::call("make:model", [
            'name' => $modelDestinationNamespace,
        ]);

        $this->info("Model created successfully in {$modelDestinationPath}");

        // Si se ha pasado la opción --migration, generar y mover la migración
        if ($createMigration) {
            Artisan::call("make:migration create_" . strtolower($name) . "_table");
            $migrationFileName = $this->getMigrationFileName($name);

            if ($migrationFileName) {
                // Definir la ruta de destino de la migración en el paquete
                $migrationDestinationPath = base_path("packages/{$vendor}/{$package}/database/migrations/{$migrationFileName}");

                // Crear las carpetas necesarias si no existen
                $filesystem = new Filesystem();
                $migrationDirectoryPath = dirname($migrationDestinationPath);
                if (!$filesystem->exists($migrationDirectoryPath)) {
                    $filesystem->makeDirectory($migrationDirectoryPath, 0755, true);
                }

                // Mover la migración generada al paquete
                $filesystem->move(database_path("migrations/{$migrationFileName}"), $migrationDestinationPath);

                $this->info("Migration created successfully in {$migrationDestinationPath}");
            }
        }
    }

    // Función para obtener el nombre del archivo de la migración recién creada
    protected function getMigrationFileName($name)
    {
        // Buscar el archivo de migración generado en la carpeta database/migrations
        $files = glob(database_path('migrations/*.php'));

        foreach ($files as $file) {
            if (str_contains($file, 'create_' . strtolower($name) . '_table')) {
                return basename($file);
            }
        }

        return null;
    }
}

