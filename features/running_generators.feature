Feature: Running rails generate commands produces migration files in the correct database migration folders
  
  'rails generate migration CreateXxxxxTable' should create a migration file in the 'migrate' folder in a single database app
  'rails generate migration CreateXxxxxTable database=default' should create a migration file in the 'migrate' folder in a multi-database app
  'rails generate migration CreateXxxxxTable database=users' should create a migration file in the 'users_migrate' folder in a multi-database app 
  'rails generate migration CreateXxxxxTable database=widgets' should create a migration file in the 'widgets_migrate' folder in a multi-database app
  'rails generate migration CreateXxxxxTable' should create migration files in 'migrate' and 'users_migrate' and 'widgets_migrate' folders
  
  Background: 
    Given empty databases have been created for the app

  Scenario: Running a rails generate migration in a single database app
    Given I run `rails generate migration CreateFoolsTable` in a single database app
    Then I should see the db/migrate folder
    And I should see a migration file in the db/migrate folder
