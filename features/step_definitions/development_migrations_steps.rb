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
    users_table = db.execute( "SELECT name FROM sqlite_master WHERE type='table' AND name='users'" ) 
    expect(users_table[0][0]).to eq "users"
  end
end

Then(/^I should see the correct columns in the users table$/) do
  SQLite3::Database.new( "single-db-dummy/db/development.sqlite3" ) do |db|
    users_columns = db.execute( "PRAGMA table_info(users)" ) 
    column_names = users_columns.map do |column|
      column[1]
    end
    expect(column_names).to include "name" 
    expect(column_names).to include "email" 
    expect(column_names).to include "age" 
  end
end

When(/^I create a database migration on the default database in a multi database app$/) do
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

  write_file "../../multi-db-dummy/db/migrate/20151010142141_" + "create_posts_table.rb",  migration
end

When(/^It creates a posts table with columns called 'title' and 'text' and 'author'$/) do
  # This line describes what was created in the migration
end

When(/^I create another database migration on the users database in a multi database app$/) do
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

  write_file "../../multi-db-dummy/db/users_migrate/20151010141234_" + "create_accounts_table.rb",  migration
end

When(/^It creates an accounts table with columns called 'expense' and 'user_id' and 'total'$/) do
  # This line shows which columns are created on the users database accounts table.
end

When(/^I create another database migration on the widgets database in a multi database app$/) do
  migration = <<-MIGRATION_END
    class CreateWidgetsTable < ActiveRecord::Migration
      def change
        create_table :gadgets do |column|
          column.string  :doobry
          column.integer :wotsit
          column.string  :thingy
        end
      end 
    end
  MIGRATION_END

  write_file "../../multi-db-dummy/db/widgets_migrate/20151010145432_" + "create_widgets_table.rb",  migration
end

When(/^It creates an gadgets table with columns called 'doobry' and 'wotsit' and 'thingy'$/) do
  # This line shows which columns are created on the widgets database gadgets table.
end

Then(/^I should see the created posts table in the default database$/) do
  SQLite3::Database.new( "multi-db-dummy/db/development.sqlite3" ) do |db|
    posts_table = db.execute( "SELECT name FROM sqlite_master WHERE type='table' AND name='posts'" ) 
    expect(posts_table[0][0]).to eq "posts"
  end
end

Then(/^I should see the created '([^']*)' table in the '([^']*)' database$/) do |table, database|
  if database == "default"
    database_file_name = "development"
  else
    database_file_name = "#{database}_development"
  end
  SQLite3::Database.new( "multi-db-dummy/db/#{database_file_name}.sqlite3" ) do |db|
    accounts_table = db.execute( "SELECT name FROM sqlite_master WHERE type='table' AND name='#{table}'" )
    expect(accounts_table[0][0]).to eq table
  end
end

Then(/^I should see the "([^"]*)", "([^"]*)" and "([^"]*)" columns in the "([^"]*)" table in the "([^"]*)" database$/) do |column1, column2, column3, table, database|
  if database == "default"
    database_file_name = "development"
  else
    database_file_name = "#{database}_development"
  end
  SQLite3::Database.new( "multi-db-dummy/db/#{database_file_name}.sqlite3" ) do |db|
    users_columns = db.execute( "PRAGMA table_info(#{table})" )
    column_names = users_columns.map { |column| column[1] }
    expect(column_names).to include column1
    expect(column_names).to include column2
    expect(column_names).to include column3
  end
end


# Helpers

def run_rake_db_create
  cmd = unescape_text("rake db:create")
  cmd = extract_text(cmd) if !aruba.config.keep_ansi || aruba.config.remove_ansi_escape_sequences

  run_simple(cmd, false)
end