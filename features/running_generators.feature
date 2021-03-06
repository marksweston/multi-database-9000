Feature: Running rails generate commands produces migration files in the correct database migration folders
  
  'rails generate migration CreateXxxxxTable' should create a migration file in the 'migrate' folder in a single database app
  'rails generate multi_migration CreateXxxxxTable' should create a migration file in the 'migrate' folder in a multi-database app
  'rails generate multi_migration CreateXxxxxTable default' should create a migration file in the 'migrate' folder in a multi-database app
  'rails generate multi_migration CreateXxxxxTable users' should create a migration file in the 'users_migrate' folder in a multi-database app 
  'rails generate multi_migration CreateXxxxxTable widgets' should create a migration file in the 'widgets_migrate' folder in a multi-database app
  
  Background: 
    Given empty databases have been created for the app

  Scenario: Running 'rails generate migration' in a single database app
    Given There is no db/migrate folder before a migration is generated in a single database app
    And I run `rails generate migration CreateFoolsTable` in a single database app
    Then I should see the db/migrate folder in a single database app
    And I should see a migration file in the db/migrate folder in a single database app

  Scenario: Running 'rails generate migration' in a multi database app
    Given There are no migration folders before a migration is generated in a multi database app
    And I run `rails generate migration CreateFoolsTable` in a multi database app
    Then I should see the db/migrate folder for the default database

  Scenario: Running 'rails generate multi_migration' in a multi database app
    Given There are no migration folders before a migration is generated in a multi database app
    And I run `rails generate multi_migration CreateFoolsTable` in a multi database app
    Then I should see the db/migrate folder for the default database

  Scenario: Running "rails generate multi_migration <database_name>" in a multi database app
    Given There are no migration folders before a migration is generated in a multi database app
    And I run `rails generate multi_migration CreateFoolsTable default` in a multi database app
    Then I should see the db/migrate folder for the default database

    And I should see a migration file in the db/migrate folder in a multi database app
    And I run `rails generate multi_migration CreateFoolsTable users` in a multi database app
    Then I should see the db/users_migrate folder for the default database
    And I should see a migration file in the db/users_migrate folder in a multi database app
    And I run `rails generate multi_migration CreateFoolsTable widgets` in a multi database app
    Then I should see the db/widgets_migrate folder for the default database
    And I should see a migration file in the db/widgets_migrate folder in a multi database app
