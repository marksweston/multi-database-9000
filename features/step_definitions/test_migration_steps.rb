Given(/^A development database with a "([^"]*)" table with columns "([^"]*)", "([^"]*)" and "([^"]*)"$/) do |table, column1, column2, column3|
  write_single_db_migration
  run_task_in_single_db_app "bundle exec rake db:migrate"
end

When(/^I run a model test$/) do
  test_file = <<-TEST_FILE_END
    require 'test_helper'

    class UserTest < ActiveSupport::TestCase
      test "should save" do
        user = User.new
        assert user.save
      end
    end
  TEST_FILE_END

  write_file "../../single-db-dummy/test/models/user_test.rb", test_file

  run_task_in_single_db_app "bundle exec rake test"
end

Then(/^I should see the created users table in the default test database$/) do
  table_exists? :app => "single-db-dummy", :database => "test.sqlite3", :table => "users"
end

Then(/^I should see the correct columns in the users table in the default test database$/) do
  columns_exist? app: "single-db-dummy", :database => "test.sqlite3", :table => "users", :columns => ["name", "email", "age"]
end

Given(/^A "([^"]*)" development database with a "([^"]*)" table with columns "([^"]*)", "([^"]*)" and "([^"]*)"$/) do |database, table, column1, column2, column3|
  write_migration_for_default_db
  write_migration_for_users_db
  write_migration_for_widgets_db
  run_task_in_multi_db_app "bundle exec rake db:migrate"
end

When(/^I run a model test in the multi\-database app$/) do
  test_file = <<-TEST_FILE_END
    require 'test_helper'

    class GadgetTest < ActiveSupport::TestCase
      test "should save" do
        gadget = Gadget.new
        assert gadget.save
      end
    end
  TEST_FILE_END

  write_file "../../multi-db-dummy/test/models/gadget_test.rb", test_file

  run_task_in_multi_db_app "bundle exec rake test"
end

Then(/^I should see the created "([^"]*)" table in the "([^"]*)" test database$/) do |table, database|
  if database == "default"
    database_file = "test"
  else
    database_file = "#{database}_test"
  end
  table_exists? :app => "multi-db-dummy", :database => "#{database_file}.sqlite3", :table => table
end


# helpers

def table_exists?(app:, database:, table:)
  SQLite3::Database.new( "#{app}/db/#{database}" ) do |db|
    table_query = db.execute( "SELECT name FROM sqlite_master WHERE type='table' AND name='#{table}'" )
    expect(table_query[0][0]).to eq table
  end
end

def columns_exist?(app:, database:, table:, columns:)
  SQLite3::Database.new( "#{app}/db/#{database}" ) do |db|
    users_columns = db.execute( "PRAGMA table_info(#{table})" )
    column_names = users_columns.map do |column|
      column[1]
    end
    columns.each do |test_column|
      expect(column_names).to include test_column
    end
  end
end