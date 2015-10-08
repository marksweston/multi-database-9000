Feature: Migrations run for all databases in the app

  rake db:migrate should still work in a single database app
  rake db:migrate should migrate all the databases in a multi-database app
  rake db:migrate DATABASE=users should migrate the users database only

  Background:
    Given empty databases have been created for the app

  Scenario: User runs a migration in a single database app
    When I create a database migration in a single database app    
    And It creates a users table with columns called 'name' and 'age' and 'email'
    And  I run `bundle exec rake db:migrate` in a single database app
    Then I should see the created users table 
    And I should see the correct columns in the users table

  Scenario: The schema is updated when migrations are run in a single database app
    When I run a migration with the timestamp "2015101014214" in a single database app
    Then the file "db/schema.rb" should exist
    And the version in the schema file should be updated

  Scenario: User runs a migration in a multi database app
    When I create a database migration on the default database in a multi database app
    And It creates a posts table with columns called 'title' and 'text' and 'author'
    And I create another database migration on the users database in a multi database app
    And It creates an accounts table with columns called 'expense' and 'user_id' and 'total'
    And I create another database migration on the widgets database in a multi database app
    And It creates an gadgets table with columns called 'doobry' and 'wotsit' and 'thingy'
    And  I run `bundle exec rake db:migrate` in a multi database app
    Then I should see the created 'posts' table in the 'default' database
    And I should see the created 'accounts' table in the 'users' database
    And I should see the created 'gadgets' table in the 'widgets' database
    And I should see the "title", "text" and "author" columns in the "posts" table in the "default" database
    And I should see the "expense", "user_id" and "total" columns in the "accounts" table in the "users" database
    And I should see the "doobry", "wotsit" and "thingy" columns in the "gadgets" table in the "widgets" database

