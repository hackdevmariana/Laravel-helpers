<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Filesystem\Filesystem;

class MakePackageModel extends Command
{
    protected $signature = 'make:package-model {name} {--package=} {--migration}';
    protected $description = 'Create a model and migration in a specific package directory';

    public function handle()
    {
        $name = $this->argument('name');
        $package = $this->option('package') ?? 'webworks';
        $createMigration = $this->option('migration');
        
        // Generar el modelo temporalmente en app/Models
        Artisan::call("make:model Models/{$name}");

        // Definir la ruta destino del modelo en el paquete
        $modelDestinationPath = base_path("packages/works/{$package}/src/Models/{$name}.php");
        
        // Mover el modelo generado al paquete
        $filesystem = new Filesystem();
        $filesystem->move(app_path("Models/{$name}.php"), $modelDestinationPath);
        
        // Ajustar el namespace del modelo en la nueva ubicación
        $this->updateNamespace($modelDestinationPath, "Works\\{$package}\\Models");

        $this->info("Model created successfully in {$modelDestinationPath}");
        
        // Si se ha pasado la opción --migration, generar y mover la migración
        if ($createMigration) {
            Artisan::call("make:migration create_" . strtolower($name) . "_table");
            $migrationFileName = $this->getMigrationFileName($name);

            if ($migrationFileName) {
                // Mover la migración generada a la carpeta del paquete
                $migrationDestinationPath = base_path("packages/works/{$package}/database/migrations/{$migrationFileName}");
                $filesystem->move(database_path("migrations/{$migrationFileName}"), $migrationDestinationPath);

                $this->info("Migration created successfully in {$migrationDestinationPath}");
            }
        }
    }

    // Función para actualizar el namespace del modelo
    protected function updateNamespace($filePath, $newNamespace)
    {
        $fileContents = file_get_contents($filePath);
        $fileContents = str_replace('namespace App\Models;', "namespace {$newNamespace};", $fileContents);
        file_put_contents($filePath, $fileContents);
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
