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