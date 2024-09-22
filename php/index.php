<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laravel Server Validator</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
</head>

<body>
    <div class="container mt-5">
        <h1 class="mb-4">Laravel Server Validator</h1>
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>Check</th>
                    <th>Status</th>
                    <th>Details</th>
                </tr>
            </thead>
            <tbody>
                <?php
                // Extensiones requeridas para Laravel
                $requiredExtensions = ['bcmath', 'ctype', 'fileinfo', 'json', 'mbstring', 'openssl', 'pdo', 'tokenizer', 'xml', 'curl'];
                
                // Verificación de la versión de PHP
                $phpVersion = phpversion();
                $phpVersionCheck = version_compare($phpVersion, '8.1', '>=');
                ?>
                <!-- Verificación de la versión de PHP -->
                <tr>
                    <td>PHP Version</td>
                    <td class="<?php echo $phpVersionCheck ? 'table-success' : 'table-warning'; ?>">
                        <?php echo $phpVersionCheck ? 'Ok' : 'Bad'; ?>
                    </td>
                    <td>The server has PHP version <?php echo $phpVersion; ?></td>
                </tr>

                <!-- Verificación de extensiones de PHP -->
                <?php foreach ($requiredExtensions as $extension): ?>
                    <tr>
                        <td><?php echo ucfirst($extension); ?> Extension</td>
                        <td class="<?php echo extension_loaded($extension) ? 'table-success' : 'table-warning'; ?>">
                            <?php echo extension_loaded($extension) ? 'Ok' : 'Bad'; ?>
                        </td>
                        <td><?php echo extension_loaded($extension) ? 'The extension is loaded' : 'The extension is not loaded'; ?>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>

        <!-- Enlace a phpinfo() para más detalles -->
        <div class="mt-4">
            <a href="phpinfo.php" class="btn btn-primary">View PHP Info</a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-kenU1KFdBIe4zVF0s0G1M5b4hcpxyD9F7jL+jjXkk+Q2h455rYXK/7HAuoJl+0I4" crossorigin="anonymous"></script>
</body>

</html>
