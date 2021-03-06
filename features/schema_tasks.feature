Feature: rake schema tasks should work for all databases in the app

  rake db:schema:load will load all the database schemas for the current environment
  rake db:schema:load DATABASE=widgets will load the schema for the widgets database
  the schema_migrations table for each database should be correctly updated with migrations run on that database only

  Background:
    Given empty databases have been created for the app

  Scenario: User loads the schema in a single database app
    Given a single database app and a schema file with:
      """
      ActiveRecord::Schema.define(version: 20151010145432) do

        create_table "users", force: :cascade do |t|
          t.string  "name"
          t.integer "age"
          t.string  "email"
        end

      end
      """
    When I run `bundle exec rake db:schema:load` in a single database app
    Then I should see the created users table
    And I should see the correct columns in the users table

  Scenario: User loads the schema in a multi database app
    Given a multi database app and a schema file with:
      """
      ActiveRecord::Schema.define(version: 20151010142141) do

        create_table "posts", force: :cascade do |t|
          t.string  "title"
          t.integer "text"
          t.string  "author"
        end

      end
      """
    And a users_schema file with:
      """
      ActiveRecord::Schema.define(version: 20151010141234) do

        create_table "accounts", force: :cascade do |t|
          t.string  "expense"
          t.integer "user_id"
          t.string  "total"
        end

      end
      """
    And a widgets_schema file with:
      """
      ActiveRecord::Schema.define(version: 20151010141234) do

        create_table "accounts", force: :cascade do |t|
          t.string  "doobry"
          t.integer "wotsit"
          t.string  "thingy"
        end

      end
      """
    When I run `bundle exec rake db:schema:load` in the multi database app
    Then I should see the created 'posts' table in the 'default' database
    And I should see the created 'accounts' table in the 'users' database
    And I should see the "title", "text" and "author" columns in the "posts" table in the "default" database
    And I should see the "expense", "user_id" and "total" columns in the "accounts" table in the "users" database

  Scenario: loading the schema in the production environment
    Given a multi database app and a schema file with:
      """
      ActiveRecord::Schema.define(version: 20151010142141) do

        create_table "posts", force: :cascade do |t|
          t.string  "title"
          t.integer "text"
          t.string  "author"
        end

      end
      """
    And a users_schema file with:
      """
      ActiveRecord::Schema.define(version: 20151010141234) do

        create_table "accounts", force: :cascade do |t|
          t.string  "expense"
          t.integer "user_id"
          t.string  "total"
        end

      end
      """
    And a widgets_schema file with:
      """
      ActiveRecord::Schema.define(version: 20151010141234) do

        create_table "accounts", force: :cascade do |t|
          t.string  "doobry"
          t.integer "wotsit"
          t.string  "thingy"
        end

      end
      """
    When I run `bundle exec rake db:schema:load RAILS_ENV=production` in the multi database app
    Then I should see the created 'posts' table in the 'default' 'production' database
    And I should see the created 'accounts' table in the 'users' 'production' database
    And I should see the "title", "text" and "author" columns in the "posts" table in the "default" "production" database
    And I should see the "expense", "user_id" and "total" columns in the "accounts" table in the "users" "production" database

  Scenario: checking the schema_migrations table after running rake db:schema:load
    Given a multi database app and a schema file with:
      """
      ActiveRecord::Schema.define(version: 20151010142141) do

        create_table "posts", force: :cascade do |t|
          t.string  "title"
          t.integer "text"
          t.string  "author"
        end

      end
      """
    And a users_schema file with:
      """
      ActiveRecord::Schema.define(version: 20151010141234) do

        create_table "accounts", force: :cascade do |t|
          t.string  "expense"
          t.integer "user_id"
          t.string  "total"
        end

      end
      """
    And the following migrations have already been run:
      | Migration                               | database|
      | 20151008140000_create_posts_table.rb    | default |
      | 20151009140000_update_posts_table.rb    | default |
      | 20151010142141_change_posts_table.rb    | default |
      | 20151008220000_create_accounts_table.rb | users   |
      | 20151009220000_update_accounts_table.rb | users   |
      | 20151010141234_change_gadgets_table.rb  | users   |
    When I run `bundle exec rake db:schema:load` in the multi database app
    Then the schema_migrations table for the "default" database should only contain version numbers from default database migrations
    And the schema_migrations table for the "users" database should only contain version numbers from users database migrations