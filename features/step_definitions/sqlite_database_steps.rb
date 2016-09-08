
Given(/^no databases have been created$/) do
  clear_db_dir
end

Given(/^I run `([^`]*)` in (?:a|the) single database app$/) do |command|
  run_task_in_single_db_app(command)
end

Given(/^A single database app with an existing database$/) do
  run_task_in_single_db_app("bundle exec rake db:create")
end

Given(/^A multi\-database app with existing databases$/) do
  run_task_in_multi_db_app("bundle exec rake db:create")
end

Given(/^I run `([^`]*)` in (?:a|the) multi database app$/) do |command|
  run_task_in_multi_db_app(command)
end

Then(/^I will have deleted all the databases$/) do
  expect(Dir.entries("single-db-dummy/db")).to_not include(match /.sqlite3/)
end

Then(/^I will have deleted all the databases in the multi database app$/) do
  expect(Dir.entries("multi-db-dummy/db")).to_not include(match /.sqlite3/)
end

Then(/^I will have deleted the "([^"]*)" databases from the multi database app$/) do |arg1|
  expect(Dir.entries("multi-db-dummy/db")).to_not include(match /users/)
  expect(Dir.entries("multi-db-dummy/db")).to include(match /widgets/)
  expect(Dir.entries("multi-db-dummy/db")).to include(match /test/)
  expect(Dir.entries("multi-db-dummy/db")).to include(match /development/)
  expect(Dir.entries("multi-db-dummy/db").count).to eq 6
end

Then(/^I will have only deleted the "([^"]*)" database$/) do |arg1|
  expect(Dir.entries("multi-db-dummy/db")).to_not include(match /widgets_test/)
  expect(Dir.entries("multi-db-dummy/db")).to include(match /widgets/)
  expect(Dir.entries("multi-db-dummy/db")).to include(match /users/)
  expect(Dir.entries("multi-db-dummy/db")).to include(match /test/)
  expect(Dir.entries("multi-db-dummy/db")).to include(match /development/)
  expect(Dir.entries("multi-db-dummy/db").count).to eq 7
end



#helper

def run_task_in_single_db_app(command)
  cmd = unescape_text(command)
  cmd = extract_text(cmd) if !aruba.config.keep_ansi || aruba.config.remove_ansi_escape_sequences

  cd "../../single-db-dummy" do
    run_simple(cmd, false)
  end
end

def run_task_in_multi_db_app(command)
  cmd = unescape_text(command)
  cmd = extract_text(cmd) if !aruba.config.keep_ansi || aruba.config.remove_ansi_escape_sequences

  cd "../../multi-db-dummy" do
    run_simple(cmd, false)
  end
end

def clear_db_dir
  remove("../../single-db-dummy/db", :force => true)
  remove("../../multi-db-dummy/db", :force => true)
  create_directory "../../single-db-dummy/db"
  create_directory "../../multi-db-dummy/db"
end