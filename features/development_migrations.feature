Feature: Migrations run for all databases in the app

  rake db:migrate should still work in a single database app
  rake db:migrate should migrate all the databases in a multi-database app
  rake db:migrate DATABASE=users should migrate the users database only
  rake db:migrate:status should list all migrations for all databases, ordered by timestamp.
  The migrations list should include an extra column listing the database each migration is for.

  Status   Migration ID    Database        Migration Name
  --------------------------------------------------
    up     20151010141234  users           Create accounts table
    up     20151010142141  default         Create posts table
    up     20151010145432  widgets         Create widgets table

  Background:
    Given empty databases have been created for the app

  Scenario: User runs a migration in a single database app
    When I create a database migration in a single database app    
    And It creates a users table with columns called 'name' and 'age' and 'email'
    And  I run `bundle exec rake db:migrate` in a single database app
    Then I should see the created users table 
    And I should see the correct columns in the users table

  Scenario: The schema is updated when migrations are run in a single database app
    When I run a migration with the timestamp "20151010142141" in a single database app
    Then the file "../../single-db-dummy/db/schema.rb" should exist
    And the version in the schema file should be updated

  Scenario: User runs a migration in a multi database app
    When I create a database migration on the default database in a multi database app
    And It creates a posts table with columns called 'title' and 'text' and 'author'
    And I create another database migration on the users database in a multi database app
    And It creates an accounts table with columns called 'expense' and 'user_id' and 'total'
    And I create another database migration on the widgets database in a multi database app
    And It creates a gadgets table with columns called 'doobry' and 'wotsit' and 'thingy'
    And  I run `bundle exec rake db:migrate` in a multi database app
    Then I should see the created 'posts' table in the 'default' database
    And I should see the created 'accounts' table in the 'users' database
    And I should see the created 'gadgets' table in the 'widgets' database
    And I should see the "title", "text" and "author" columns in the "posts" table in the "default" database
    And I should see the "expense", "user_id" and "total" columns in the "accounts" table in the "users" database
    And I should see the "doobry", "wotsit" and "thingy" columns in the "gadgets" table in the "widgets" database

  Scenario: The schema is updated when migrations are run in a multi database app
    When I run migrations with the following timestamps "20151010142141", "20151010141234" and "20151010145432" in a multi-database app
    Then the file "../../multi-db-dummy/db/schema.rb" should exist
    Then the file "../../multi-db-dummy/db/users_schema.rb" should exist
    Then the file "../../multi-db-dummy/db/widgets_schema.rb" should exist
    And the versions in the schema files should be updated

  Scenario: Specifying the database to migrate using the DATABASE environment variable
    Given There is a migration with the timestamp "20151010141234" for the users database
    When I run `bundle exec rake db:migrate DATABASE=users` in a multi database app
    Then the file "../../multi-db-dummy/db/users_schema.rb" should exist
    And the file "../../multi-db-dummy/db/widgets_schema.rb" should not exist
    And the file "../../multi-db-dummy/db/schema.rb" should not exist
    And the version in the users schema file should be updated

  Scenario: Specifying the database and the environment variables to migrate to
    Given I set the environment variables to:
      | variable           | value      |
      | RAILS_ENV          | production |
    And there is a migration for the widgets database in a multi database app
    When I run `bundle exec rake db:migrate DATABASE=widgets` in a multi database app
    Then the file "../../multi-db-dummy/db/widgets_production.sqlite3" should exist
    And the file "../../multi-db-dummy/db/production.sqlite3" should not exist
    And the file "../../multi-db-dummy/db/users_production.sqlite3" should not exist
    
  Scenario: User runs rake db:migrate:status in a single database app
    Given I have created and run a migration with the name "20151010142141_create_users_table.rb", in a single database app
    And I have created but not run a migration with the name "20151010151000_add_nickname_to_users.rb", in a single database app
    When I run `bundle exec rake db:migrate:status` in a single database app
    Then the output should match /up\s+20151010142141\s+default\s+Create users table/
    And the output should match /down\s+20151010151000\s+default\s+Add nickname to users/

  Scenario: User runs rake db:migrate:status in a multi database app
    Given I have created and run the following migrations in a multi database app:
            | Migration                               | database|
            | 20151010142141_create_posts_table.rb    | default |
            | 20151010141234_create_accounts_table.rb | users   |
            | 20151010145432_create_gadgets_table.rb  | widgets |
    And I have created and not run the following migrations:
            | Migration                                 | database|
            | 20151010153000_add_address_to_accounts.rb | users   |
            | 20151010153500_add_serial_to_gadgets.rb   | widgets |
    When I run `bundle exec rake db:migrate:status` in a multi database app
    Then the output should match /up\s+20151010142141\s+default\s+Create posts table/
    Then the output should match /up\s+20151010141234\s+users\s+Create accounts table/
    Then the output should match /up\s+20151010145432\s+widgets\s+Create gadgets table/
    Then the output should match /down\s+20151010153000\s+users\s+Add address to accounts/
    Then the output should match /down\s+20151010153500\s+widgets\s+Add serial to gadgets/


