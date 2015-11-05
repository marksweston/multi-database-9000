Given(/^a single database app and a schema file with:$/) do |schema_content|
  write_file "../../single-db-dummy/db/schema.rb", schema_content
end

Given(/^a multi database app and a schema file with:$/) do |schema_content|
  write_file "../../multi-db-dummy/db/schema.rb", schema_content
end

Given(/^a (\w+) file with:$/) do |schema_name, schema_content|
  write_file "../../multi-db-dummy/db/#{schema_name}.rb", schema_content
end