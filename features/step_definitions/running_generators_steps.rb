
Given(/^There is no db\/migrate folder before a migration is generated in a single database app$/) do
  expect('../../single-db-dummy/db/migrate').not_to be_an_existing_directory
end

Then(/^I should see the db\/migrate folder in a single database app$/) do
  expect('../../single-db-dummy/db/migrate').to be_an_existing_directory
end


Then(/^I should see a migration file in the db\/migrate folder in a single database app$/) do
  expect('../../single-db-dummy/db/migrate').not_to be_empty
  expect(Dir.entries("single-db-dummy/db/migrate").last).to include "_create_fools_table.rb"
end


Given(/^There are no migration folders before a migration is generated in a multi database app$/) do
  expect('../../multi-db-dummy/db/migrate').not_to be_an_existing_directory
  expect('../../multi-db-dummy/db/users_migrate').not_to be_an_existing_directory
  expect('../../multi-db-dummy/db/widgets_migrate').not_to be_an_existing_directory
end

Then(/^I should see the db\/migrate folder for the default database$/) do
  expect('../../multi-db-dummy/db/migrate').to be_an_existing_directory
end

Then(/^I should see a migration file in the db\/migrate folder in a multi database app$/) do
  expect('../../multi-db-dummy/db/migrate').not_to be_empty
  expect(Dir.entries("multi-db-dummy/db/migrate").last).to include "_create_fools_table.rb"
end

Then(/^I should see the db\/users_migrate folder for the default database$/) do
   expect('../../multi-db-dummy/db/users_migrate').to be_an_existing_directory
end

Then(/^I should see a migration file in the db\/users_migrate folder$/) do
  pending # Write code here that turns the phrase above into concrete actions
end