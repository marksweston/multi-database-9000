Given(/^no databases have been created$/) do
  remove("../../single-db-dummy/db", :force => true)
  remove("../../multi-db-dummy/db", :force => true)
  create_directory "../../single-db-dummy/db"
  create_directory "../../multi-db-dummy/db"
end

Given(/^I run `([^`]*)` in a single database app$/) do |command|
  run_task_in_single_db_app(command)
end


Given(/^I run `([^`]*)` in a multi database app$/) do |command|
  run_task_in_multi_db_app(command)
end


#helper

def run_task_in_single_db_app(command)
  cd "../../single-db-dummy"

  run_rake_db_task command
end

def run_task_in_multi_db_app(command)
  cd "../../multi-db-dummy"

  run_rake_db_task command
end

def run_rake_db_task command
  cmd = unescape_text(command)
  cmd = extract_text(cmd) if !aruba.config.keep_ansi || aruba.config.remove_ansi_escape_sequences

  run_simple(cmd, false)
end