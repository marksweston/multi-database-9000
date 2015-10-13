Feature: Migrations run for all databases in the app in the production environment

  rake db:migrate should still work in a single database app
  rake db:migrate should migrate all the databases in a multi-database app

  Background:
    Given I set the environment variables to:
      | variable   | value      |
      | RAILS_ENV  | production |  
    And empty databases have been created for the app

  Scenario: User runs a migration in a single database app in the production environment
    When I create a database migration in a single database app    
    And It creates a users table with columns called 'name' and 'age' and 'email'
    And  I run `bundle exec rake db:migrate` in a single database app
    Then I should see the created users table in the production environment
    And I should see the correct columns in the users table in the production environment

  Scenario: User runs a migration in a multi database app in the production environment
    When I create a database migration on the default database in a multi database app
    And It creates a posts table with columns called 'title' and 'text' and 'author'
    And I create another database migration on the users database in a multi database app
    And It creates an accounts table with columns called 'expense' and 'user_id' and 'total'
    And I create another database migration on the widgets database in a multi database app
    And It creates a gadgets table with columns called 'doobry' and 'wotsit' and 'thingy'
    And  I run `bundle exec rake db:migrate` in a multi database app
    Then I should see the created "posts" table in the "default" database in the production environment
    And I should see the created "accounts" table in the "users" database in the production environment
    And I should see the created "gadgets" table in the "widgets" database in the production environment
    And I should see the "title", "text" and "author" columns in the "posts" table in the "default" database in the production environment
    And I should see the "expense", "user_id" and "total" columns in the "accounts" table in the "users" database in the production environment
    And I should see the "doobry", "wotsit" and "thingy" columns in the "gadgets" table in the "widgets" database in the production environment