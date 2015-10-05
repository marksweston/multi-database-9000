Given(/^empty databases have been created for the app$/) do 
  cd "#{root_path}/single-db-dummy"

  cmd = unescape_text("rake db:create")
  cmd = extract_text(cmd) if !aruba.config.keep_ansi || aruba.config.remove_ansi_escape_sequences

  run_simple(cmd, false)

  cd "#{root_path}/multi-db-dummy"

  cmd = unescape_text("rake db:create")
  cmd = extract_text(cmd) if !aruba.config.keep_ansi || aruba.config.remove_ansi_escape_sequences

  run_simple(cmd, false)
end




When(/^I run a migration in a single database app$/) do
  pending # Write code here that turns the phrase above into concrete actions
end


# Helpers

def root_path
  puts __dir__ + "/../../"
  __dir__ + "/../../"
end 

