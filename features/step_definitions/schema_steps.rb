require 'pry'

Given(/^a single database app and a schema file with:$/) do |schema_content|
  write_file "../../single-db-dummy/db/schema.rb", schema_content
end

Given(/^a multi database app and a schema file with:$/) do |schema_content|
  write_file "../../multi-db-dummy/db/schema.rb", schema_content
end

Given(/^a (\w+) file with:$/) do |schema_name, schema_content|
  write_file "../../multi-db-dummy/db/#{schema_name}.rb", schema_content
end

Given(/^the following migrations have already been run:$/) do |table|
  @version_numbers = Hash.new {|hash, missing_key| hash[missing_key] = []}
  table.hashes.each{|migration| @version_numbers[migration["database"]] << migration["Migration"].match(/\d{14}/).to_s}
  table.hashes.each do |migration|
    write_multi_db_migration_for migration["database"], migration["Migration"]
  end
end

Then(/^the schema_migrations table for the "([^"]*)" database should only contain version numbers from (?:\w+) database migrations$/) do |database|
  if database == "default"
    database_file = "development.sqlite3"
  else
    database_file = "#{database}_development.sqlite3"
  end
  SQLite3::Database.new("multi-db-dummy/db/#{database_file}") do |db|
    versions_query = db.execute("SELECT version FROM schema_migrations ORDER BY version ASC")
    puts versions_query
    expect(versions_query.count).to eql @version_numbers[database].count
    expect(versions_query.flatten).to match_array @version_numbers[database]
  end
end