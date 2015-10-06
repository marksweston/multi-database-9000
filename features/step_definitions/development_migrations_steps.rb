Given(/^empty databases have been created for the app$/) do
  cd "../../single-db-dummy" do
    run_rake_db_create
  end

  cd "../../multi-db-dummy" do
    run_rake_db_create
  end
end




When(/^I run a migration in a single database app$/) do
  pending # Write code here that turns the phrase above into concrete actions
end


# Helpers

def root_path
  return File.expand_path("../..", __dir__)
end 

def run_rake_db_create
  cmd = unescape_text("rake db:create")
  cmd = extract_text(cmd) if !aruba.config.keep_ansi || aruba.config.remove_ansi_escape_sequences

  run_simple(cmd, false)
end