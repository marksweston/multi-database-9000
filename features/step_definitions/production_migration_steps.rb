require 'sqlite3'
require 'pry'

Then(/^I should see the created users table in the production environment$/) do
  table_exists? :app => "single-db-dummy", :database => "production.sqlite3", :table => "users"
end

Then(/^I should see the correct columns in the users table in the production environment$/) do
  columns_exist? :app => "single-db-dummy", :database => "production.sqlite3", :table => "users", :columns => ["name", "email", "age"]
end

Then(/^I should see the created "([^"]*)" table in the "([^"]*)" database in the production environment$/) do |table, database|
  if database == "default"
    database_file_name = "production"
  else
    database_file_name = "#{database}_production"
  end
  table_exists? :app => "multi-db-dummy", :database => "#{database_file_name}.sqlite3", :table => table
end

Then(/^I should see the "([^"]*)", "([^"]*)" and "([^"]*)" columns in the "([^"]*)" table in the "([^"]*)" database in the production environment$/) do |column1, column2, column3, table , database|
  if database == "default"
    database_file_name = "production"
  else
    database_file_name = "#{database}_production"
  end
  columns_exist? :app => "multi-db-dummy", :database => "#{database_file_name}.sqlite3", :table => table, :columns => [column1, column2, column3]
end