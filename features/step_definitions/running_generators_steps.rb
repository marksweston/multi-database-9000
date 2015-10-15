
Then(/^I should see the db\/migrate folder$/) do
  expect('../../single-db-dummy/db/migrate').to be_an_existing_directory
end


Then(/^I should see a migration file in the db\/migrate folder$/) do
  expect('../../single-db-dummy/db/migrate').not_to be_empty
end




