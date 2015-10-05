Feature: Running rake db:create

  rake db:create should create all the databases in a multi-database app
  rake db:create should still work in a single database app
  rake db:create DATABASE=users should create the users database only

  Background:
    Given no databases have been created

  Scenario: creating the database in a single database app
    When I run `bundle exec rake db:create` in a single database app
    Then the file "db/development.sqlite3" should exist
    And the file "db/test.sqlite3" should exist

  Scenario: creating the database in a multi database app
    When I run `bundle exec rake db:create` in a multi database app
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
    When I run `bundle exec rake db:create DATABASE=users` in a multi database app
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
    Given I set the environment variables to:
      | variable           | value      |
      | RAILS_ENV          | test       |
    When I run `bundle exec rake db:create` in a multi database app
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
    Given I set the environment variables to:
      | variable           | value      |
      | RAILS_ENV          | production |
    When I run `bundle exec rake db:create DATABASE=widgets` in a multi database app
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
