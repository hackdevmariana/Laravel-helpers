## Starting a project

#### With Backpack

Installing Laravel, Backpack and Nuxt:

```
laravue-backpack.sh ProjectName
```

Create the directory ProjectName

And two subdirectories:
ProjectName_front for the frontend
ProjectName_back for the backend

#### With Voyager

Installing Laravel, Voyager and Nuxt:

```
laravue-voyager.sh ProjectName
```

Create the directory ProjectName

And two subdirectories:
ProjectName_front for the frontend
ProjectName_back for the backend

## Working with Laravel

```
createfiles.sh ModelName
```
Create model, controller and seeder in Laravel and Filament resource and adapts the files for simple models with a single field called "name".


```
updatedatabase.sh ModelName
```
Runs the migration and seeder for the indicated model.


```
clearcache.sh
```
Clear Laravel cache.


```
packagestructure.sh package-name
```
Creates the package structure `package-name`


```
makepackagestructure.sh vendor package
```
Creates the package structure `vendor/package`


## Check if the server meets Laravel requirements

To check if the server meets Laravel requirements you can use the two files in the php/ directory.

`index.php` -> checks if the server's PHP version is compatible with Laravel 9 - 11 (PHP > 8.1) and the usual Laravel extensions.

`phpinfo.php` -> shows the server's PHP information.
