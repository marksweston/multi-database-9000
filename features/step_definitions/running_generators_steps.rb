
Given(/^There is no db\/migrate folder before a migration is generated in a single database app$/) do
  expect('../../single-db-dummy/db/migrate').not_to be_an_existing_directory
end

Then(/^I should see the db\/migrate folder$/) do
  expect('../../single-db-dummy/db/migrate').to be_an_existing_directory
end


Then(/^I should see a migration file in the db\/migrate folder$/) do
  expect('../../single-db-dummy/db/migrate').not_to be_empty
  expect(Dir.entries("single-db-dummy/db/migrate").last).to include "_create_fools_table.rb"
end




