def test_and_development_connections
  return ActiveRecord::Base.configurations.keep_if {|key, value| key.match(/test/) || key.match(/development/)}
end

namespace :db do
  task :create => [:load_config] do
    test_and_development_connections.values.each do |database_connection|
      ActiveRecord::Tasks::DatabaseTasks.create database_connection
    end
  end
end
