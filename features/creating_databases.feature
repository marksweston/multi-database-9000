Feature: Running rake db:create

  rake db:create should create all the databases in a multi-database app
  rake db:create should still work in a single database app
  rake db:create DATABASE=users should create the users database only
  rake db:create RAILS_ENV=production should create the production databases only

  Background:
    Given no databases have been created

  Scenario: creating the database in a single database app
    When I run `bundle exec rake db:create` in a single database app
    Then the file "../../single-db-dummy/db/development.sqlite3" should exist
    And the file "../../single-db-dummy/db/test.sqlite3" should exist

  Scenario: creating the database in a multi database app
    When I run `bundle exec rake db:create` in a multi database app
    Then the following files should exist:
      |../../multi-db-dummy/db/development.sqlite3        |
      |../../multi-db-dummy/db/users_development.sqlite3  |
      |../../multi-db-dummy/db/widgets_development.sqlite3|
      |../../multi-db-dummy/db/test.sqlite3               |
      |../../multi-db-dummy/db/users_test.sqlite3         |
      |../../multi-db-dummy/db/widgets_test.sqlite3       |
    And the following files should not exist:
      |../../multi-db-dummy/db/production.sqlite3         |
      |../../multi-db-dummy/db/users_production.sqlite3   |
      |../../multi-db-dummy/db/widgets_production.sqlite3 |

  Scenario: specifying the database to create using the DATABASE environment variable
    When I run `bundle exec rake db:create DATABASE=users` in a multi database app
    Then the following files should exist:
      |../../multi-db-dummy/db/users_development.sqlite3  |
      |../../multi-db-dummy/db/users_test.sqlite3         |
    And the following files should not exist:
      |../../multi-db-dummy/db/development.sqlite3        |
      |../../multi-db-dummy/db/widgets_development.sqlite3|
      |../../multi-db-dummy/db/test.sqlite3               |
      |../../multi-db-dummy/db/widgets_test.sqlite3       |
      |../../multi-db-dummy/db/production.sqlite3         |
      |../../multi-db-dummy/db/users_production.sqlite3   |
      |../../multi-db-dummy/db/widgets_production.sqlite3 |

  Scenario: specifying the Rails environment
    Given I set the environment variables to:
      | variable           | value      |
      | RAILS_ENV          | test       |
    When I run `bundle exec rake db:create` in a multi database app
    Then the following files should exist:
      |../../multi-db-dummy/db/users_test.sqlite3         |
      |../../multi-db-dummy/db/test.sqlite3               |
      |../../multi-db-dummy/db/widgets_test.sqlite3       |
    And the following files should not exist:
      |../../multi-db-dummy/db/users_development.sqlite3  |
      |../../multi-db-dummy/db/development.sqlite3        |
      |../../multi-db-dummy/db/widgets_development.sqlite3|
      |../../multi-db-dummy/db/production.sqlite3         |
      |../../multi-db-dummy/db/users_production.sqlite3   |
      |../../multi-db-dummy/db/widgets_production.sqlite3 |

  Scenario: specifying the database and the Rails environment
    Given I set the environment variables to:
      | variable           | value      |
      | RAILS_ENV          | production |
    When I run `bundle exec rake db:create DATABASE=widgets` in a multi database app
    Then the following files should exist:
      |../../multi-db-dummy/db/widgets_production.sqlite3 |
    And the following files should not exist:
      |../../multi-db-dummy/db/users_test.sqlite3         |
      |../../multi-db-dummy/db/test.sqlite3               |
      |../../multi-db-dummy/db/widgets_test.sqlite3       |
      |../../multi-db-dummy/db/users_development.sqlite3  |
      |../../multi-db-dummy/db/development.sqlite3        |
      |../../multi-db-dummy/db/widgets_development.sqlite3|
      |../../multi-db-dummy/db/production.sqlite3         |
      |../../multi-db-dummy/db/users_production.sqlite3   |
