Feature: Running rake db:create

  rake db:create should create all the databases in a multi-database app
  rake db:create should still work in a single database app
  rake db:create DATABASE=users should create the users database only

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
    And the following files should not exist:
      |db/production.sqlite3         |
      |db/users_production.sqlite3   |
      |db/widgets_production.sqlite3 |

  Scenario: specifying the database to create using the DATABASE environment variable
    Given I remove the directory "../../multi-db-dummy/db"
    And a directory named "../../multi-db-dummy/db"
    When I cd to "../../multi-db-dummy"
    And I run `bundle exec rake db:create DATABASE=users`
    Then the following files should exist:
      |db/users_development.sqlite3  |
      |db/users_test.sqlite3         |
    And the following files should not exist:
      |db/development.sqlite3        |
      |db/widgets_development.sqlite3|
      |db/test.sqlite3               |
      |db/widgets_test.sqlite3       |
      |db/production.sqlite3         |
      |db/users_production.sqlite3   |
      |db/widgets_production.sqlite3 |

  Scenario: specifying the Rails environment
    Given I remove the directory "../../multi-db-dummy/db"
    And a directory named "../../multi-db-dummy/db"
    When I cd to "../../multi-db-dummy"
    Given I set the environment variables to:
      | variable           | value      |
      | RAILS_ENV          | test       |
    And I run `bundle exec rake db:create`
    Then the following files should exist:
      |db/users_test.sqlite3         |
      |db/test.sqlite3               |
      |db/widgets_test.sqlite3       |
    And the following files should not exist:
      |db/users_development.sqlite3  |
      |db/development.sqlite3        |
      |db/widgets_development.sqlite3|
      |db/production.sqlite3         |
      |db/users_production.sqlite3   |
      |db/widgets_production.sqlite3 |

  Scenario: specifying the database and the Rails environment
    Given I remove the directory "../../multi-db-dummy/db"
    And a directory named "../../multi-db-dummy/db"
    When I cd to "../../multi-db-dummy"
    Given I set the environment variables to:
      | variable           | value      |
      | RAILS_ENV          | production |
    And I run `bundle exec rake db:create DATABASE=widgets`
    Then the following files should exist:
      |db/widgets_production.sqlite3 |
    And the following files should not exist:
      |db/users_test.sqlite3         |
      |db/test.sqlite3               |
      |db/widgets_test.sqlite3       |
      |db/users_development.sqlite3  |
      |db/development.sqlite3        |
      |db/widgets_development.sqlite3|
      |db/production.sqlite3         |
      |db/users_production.sqlite3   |
