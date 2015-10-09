Feature: Running migrations and test preparation for all database in the app

Background:
  Given empty databases have been created for the app

  Scenario: Test database is correctly set up in a single-database app
    Given A development database with a "users" table with columns "name", "age" and "email"
    When I run a model test
    Then I should see the created users table in the default test database
    And I should see the correct columns in the users table in the default test database

