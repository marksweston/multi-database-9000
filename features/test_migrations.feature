Feature: Running migrations and test preparation for all database in the app

Background:
  Given empty databases have been created for the app

  Scenario: Test database is correctly set up in a single-database app
    Given A development database with a "users" table with columns "name", "age" and "email"
    When I run a model test
    Then I should see the created users table in the default test database
    And I should see the correct columns in the users table in the default test database

  Scenario: Test database is correctly set up in a multi-database app
    Given A "default" development database with a "posts" table with columns "title", "text" and "author"
    And A "users" development database with a "accounts" table with columns "user_id", "expenses" and "total"
    And A "widgets" development database with a "gadgets" table with columns "doobry", "wotsit" and "thingy"
    When I run a model test in the multi-database app
    Then I should see the created "posts" table in the "default" test database
    Then I should see the created "accounts" table in the "users" test database
    Then I should see the created "gadgets" table in the "widgets" test database



