Feature: Migrations run for all databases in the app

  rake db:migrate should still work in a single database app
  rake db:migrate should migrate all the databases in a multi-database app
  rake db:migrate DATABASE=users should migrate the users database only

  Background:
    Given empty databases have been created for the app

  Scenario: User runs a migration in a single database app
    When I run `rake db:migrate` in a single database app
