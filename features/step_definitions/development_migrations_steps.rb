require 'sqlite3'

Given(/^empty databases have been created for the app$/) do
  clear_db_dir

  cd "../../single-db-dummy" do
    run_rake_db_create
  end

  cd "../../multi-db-dummy" do
    run_rake_db_create
  end
end


When(/^I create a database migration in a single database app$/) do
  write_single_db_migration
end

When(/^It creates a users table with columns called 'name' and 'age' and 'email'$/) do
  # This line is just describing what was created in the migration. 
end

Then(/^I should see the created users table$/) do
  table_exists? :app => "single-db-dummy", :database => "development.sqlite3", :table => "users"
end

Then(/^I should see the correct columns in the users table$/) do
  columns_exist? :app => "single-db-dummy", :database => "development.sqlite3", :table => "users", :columns => ["name", "email", "age"]
end

When(/^I create a database migration on the default database in a multi database app$/) do
  write_migration_for_default_db
end

When(/^It creates a posts table with columns called 'title' and 'text' and 'author'$/) do
  # This line describes what was created in the migration
end

When(/^I create another database migration on the users database in a multi database app$/) do
  write_migration_for_users_db
end

When(/^It creates an accounts table with columns called 'expense' and 'user_id' and 'total'$/) do
  # This line shows which columns are created on the users database accounts table.
end

When(/^I create another database migration on the widgets database in a multi database app$/) do
  write_migration_for_widgets_db
end

When(/^It creates a gadgets table with columns called 'doobry' and 'wotsit' and 'thingy'$/) do
  # This line shows which columns are created on the widgets database gadgets table.
end

Then(/^I should see the created posts table in the default database$/) do
  table_exists? :database => "development.sqlite3", :table => "posts"
end

# the (?:'([^']*)' )? capture group specifies an optional group
# e.g. "I should see the created users table in the default database" will match
# e.g. "I should see the created users table in the default production database" will also match
# (and "production" will be captured in the third parameter)
Then(/^I should see the created '([^']*)' table in the '([^']*)' (?:'([^']*)' )?database$/) do |table, database, environment|
  table_exists? :app => "multi-db-dummy", :database => "#{database_file_name database, environment}.sqlite3", :table => table
end

Then(/^I should see the "([^"]*)", "([^"]*)" and "([^"]*)" columns in the "([^"]*)" table in the "([^"]*)" (?:"([^"]*)" )?database$/) do |column1, column2, column3, table, database, environment|
  columns_exist? :app => "multi-db-dummy", :database => "#{database_file_name database, environment}.sqlite3", :table => table, :columns => [column1, column2, column3]
end

When(/^I run a migration with the timestamp "([^"]*)" in a single database app$/) do |timestamp|
  @timestamp = timestamp
  write_single_db_migration
  run_task_in_single_db_app "bundle exec rake db:migrate"
end

Then(/^the version in the schema file should be updated$/) do
  version = "version: #{@timestamp}"
  expect(File.read "single-db-dummy/db/schema.rb").to match Regexp.new(version)
end

When(/^I run migrations with the following timestamps "([^"]*)", "([^"]*)" and "([^"]*)" in a multi\-database app$/) do |timestamp1, timestamp2, timestamp3|
  @timestamps = [timestamp1, timestamp2, timestamp3]
  write_migration_for_default_db
  write_migration_for_users_db
  write_migration_for_widgets_db
  run_task_in_multi_db_app "bundle exec rake db:migrate"
end


Then(/^the versions in the schema files should be updated$/) do
  version = "version: #{@timestamps[0]}"
  expect(File.read "multi-db-dummy/db/schema.rb").to match Regexp.new(version)
  version = "version: #{@timestamps[1]}"
  expect(File.read "multi-db-dummy/db/users_schema.rb").to match Regexp.new(version)
  version = "version: #{@timestamps[2]}"
  expect(File.read "multi-db-dummy/db/widgets_schema.rb").to match Regexp.new(version)
end

Given(/^I have created and run a migration with the name "([^"]*)", in a single database app$/) do |up_migration|
  @up_migration = up_migration
  write_single_db_migration
  run_task_in_single_db_app "bundle exec rake db:migrate"
end
Given(/^There is a migration with the timestamp "([^"]*)" for the users database$/) do |timestamp|
  @timestamp = [timestamp]
  write_migration_for_users_db
end

Given(/^I have created but not run a migration with the name "([^"]*)", in a single database app$/) do |down_migration|
  @down_migration = down_migration
  write_another_single_db_migration
end

Given(/^I have created and run the following migrations in a multi database app:$/) do |table|
  write_migration_for_default_db
  write_migration_for_users_db
  write_migration_for_widgets_db
  run_task_in_multi_db_app "bundle exec rake db:migrate"
end

Given(/^I have created and not run the following migrations:$/) do |table|
  table.hashes.each do |row|
    write_multi_db_migration_for row["database"], row["Migration"]
  end
end


Then(/^the version in the users schema file should be updated$/) do
  version = "version: #{@timestamp[0]}"
  expect(File.read "multi-db-dummy/db/users_schema.rb").to match Regexp.new(version)
end

And(/^there is a migration for the widgets database in a multi database app$/) do
  write_migration_for_widgets_db
end

# Helpers

def database_file_name(database, environment)
  env = environment || "development"
  if database == "default"
    return env
  else
    return "#{database}_#{env}"
  end
end

def write_multi_db_migration_for(database, migration_name)
  migration_database = database == "default" ? "migrate" : "#{database}_migrate"
  migration_class = migration_name.match(/\d+_(\w+).rb/).captures.first.split('_').map(&:capitalize).join

  migration = <<-MIGRATION_END
    class #{migration_class} < ActiveRecord::Migration
      def change
        say "changed!"
      end
    end
  MIGRATION_END

  write_file "../../multi-db-dummy/db/#{migration_database}/#{migration_name}", migration
end

def run_rake_db_create
  ["rake db:create", "rake db:create RAILS_ENV=production"].each do |command|
    cmd = unescape_text(command)
    cmd = extract_text(cmd) if !aruba.config.keep_ansi || aruba.config.remove_ansi_escape_sequences

    run_simple(cmd, false)
  end
end

def write_single_db_migration
  migration = <<-MIGRATION_END
    class CreateUsersTable < ActiveRecord::Migration
      def change
        create_table :users do |column|
          column.string  :name
          column.integer :age
          column.string  :email
        end
      end
    end
  MIGRATION_END

  write_file "../../single-db-dummy/db/migrate/20151010142141_" + "create_users_table.rb", migration
end

def write_another_single_db_migration
  migration = <<-MIGRATION_END
    class AddNicknameToUsers < ActiveRecord::Migration
      def change
        add_column :users, :nickname, :string
      end
    end
  MIGRATION_END

  write_file "../../single-db-dummy/db/migrate/20151010151000_" + "add_nickname_to_users.rb", migration
end

def write_migration_for_default_db
  migration = <<-MIGRATION_END
    class CreatePostsTable < ActiveRecord::Migration
      def change
        create_table :posts do |column|
          column.string  :title
          column.integer :text
          column.string  :author
        end
      end
    end
  MIGRATION_END

  write_file "../../multi-db-dummy/db/migrate/20151010142141_" + "create_posts_table.rb", migration
end

def write_migration_for_users_db
  migration = <<-MIGRATION_END
    class CreateAccountsTable < ActiveRecord::Migration
      def change
        create_table :accounts do |column|
          column.string  :expense
          column.integer :user_id
          column.string  :total
        end
      end
    end
  MIGRATION_END

  write_file "../../multi-db-dummy/db/users_migrate/20151010141234_" + "create_accounts_table.rb", migration
end

def write_migration_for_widgets_db
  migration = <<-MIGRATION_END
    class CreateGadgetsTable < ActiveRecord::Migration
      def change
        create_table :gadgets do |column|
          column.string  :doobry
          column.integer :wotsit
          column.string  :thingy
        end
      end
    end
  MIGRATION_END

  write_file "../../multi-db-dummy/db/widgets_migrate/20151010145432_" + "create_gadgets_table.rb", migration
end