Feature: Running rake db:drop

  rake db:drop should drop all the databases in a multi-database app
  rake db:drop should still work in a single database app
  rake db:drop DATABASE=users should drop the users database only
  rake db:drop RAILS_ENV=production should drop the production databases only

  Background:
    Given no databases have been created

  Scenario: dropping the database in a single database app
    Given A single database app with an existing database
    When I run `bundle exec rake db:drop` in the single database app
    Then I will have deleted all the databases

  Scenario: dropping the databases in a multi-database app
    Given A multi-database app with existing databases
    When I run `bundle exec rake db:drop` in the multi database app
    Then I will have deleted all the databases in the multi database app

  Scenario: specifying the database to drop using the DATABASE environment variable
    Given A multi-database app with existing databases
    When I run `bundle exec rake db:drop DATABASE=users` in the multi database app
    Then I will have deleted the "users" databases from the multi database app

  Scenario: specifying the database and the Rails environment
    Given A multi-database app with existing databases
    Given I set the environment variables to:
      | variable           | value      |
      | RAILS_ENV          | test       |
    When I run `bundle exec rake db:drop DATABASE=widgets` in a multi database app
    Then I will have only deleted the "widgets_test" database
