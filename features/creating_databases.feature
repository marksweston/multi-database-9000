Feature: Running rake db:create

  rake db:create should create all the databases in a multi-database app
  rake db:create should still work in a single database app
  rake db:create DATABASE=users should create the users database

  Scenario: creating the database in a single database app
    Given I remove the directory "../../single-db-dummy/db"
    And a directory named "../../single-db-dummy/db"
    When I cd to "../../single-db-dummy"
    And I run `bundle exec rake db:create`
    Then the file "db/development.sqlite3" should exist
    And the file "db/test.sqlite3" should exist

  Scenario: creating the database in a multi database app
    Given I remove the directory "../../multi-db-dummy/db"
    And a directory named "../../multi-db-dummy/db"
    When I cd to "../../multi-db-dummy"
    And I run `bundle exec rake db:create`
    Then the following files should exist:
      |db/development.sqlite3        |
      |db/users_development.sqlite3  |
      |db/widgets_development.sqlite3|
      |db/test.sqlite3               |
      |db/users_test.sqlite3         |
      |db/widgets_test.sqlite3       |