require 'sqlite3'
require 'pry'

Given(/^empty databases have been created for the app$/) do
  cd "../../single-db-dummy" do
    run_rake_db_create
  end

  cd "../../multi-db-dummy" do
    run_rake_db_create
  end
end

When(/^I create a database migration in a single database app$/) do
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

  write_file "../../single-db-dummy/db/migrate/20151010142141_" + "create_users_table.rb",  migration
end

When(/^It creates a users table with columns called 'name' and 'age' and 'email'$/) do
  # This line is just describing what was created in the migration. 
end

Then(/^I should see the created users table$/) do
  SQLite3::Database.new( "single-db-dummy/db/development.sqlite3" ) do |db|
    db.execute( "SELECT name FROM sqlite_master WHERE type='table' AND name='users'" ) do |table|
      puts table[0]
    end
  end
end

Then(/^I should see the correct columns in the users table$/) do
  SQLite3::Database.new( "single-db-dummy/db/development.sqlite3" ) do |db|
    db.execute( "PRAGMA table_info(users)" ) do |column|
<<<<<<< HEAD
      puts column[1]
=======
      puts column
>>>>>>> c7ed68aee85b55edb3e151bfa461165b5e0a8462
    end
  end
end

# Helpers

def run_rake_db_create
  cmd = unescape_text("rake db:create")
  cmd = extract_text(cmd) if !aruba.config.keep_ansi || aruba.config.remove_ansi_escape_sequences

  run_simple(cmd, false)
end