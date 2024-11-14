Command that creates a Laravel package with model, migration, seeder and controller for API with the structure packages/{vendor}/{package}.

To create the Web model in packages/works/web, type:

``` sh
php artisan make:package Web --vendor=works --package=web
```

It automatically creates the directories:

And creates the Web model with its migration, the WebSeeder seeder and the WebController controller.

It also creates the ServiceProvider.

```
packages/
└── works/
    └── web/
        └── src/
            ├── Controllers/
            │   └── Api/
            │       └── WebController.php
            ├── Migrations/
            │   └── <fecha>_create_webs_table.php
            ├── Models/
            │   └── Web.php
            ├── Seeders/
            │   └── WebSeeder.php
            └── WebServiceProvider.php

```
