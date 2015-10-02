def database_connections(database: nil, rails_env: nil)
  connections = connections_for_environment(rails_env)
  if database.present?
    connections.keep_if {|key, value| key.match Regexp.new(database)}
  end
  return connections
end

def connections_for_environment(rails_env)
  if rails_env.present? && rails_env != "development"
    matcher = ->(key, value){key.match(Regexp.new rails_env)}
  else
    matcher = ->(key, value){key.match(/test/) || key.match(/development/)}
  end
  return ActiveRecord::Base.configurations.keep_if &matcher
end

Rake::Task['db:create'].clear

namespace :db do
  task :create => [:load_config] do
    database_connections(:database => ENV["DATABASE"], :rails_env => ENV["RAILS_ENV"]).values.each do |database_connection|
      ActiveRecord::Tasks::DatabaseTasks.create database_connection
    end
  end
end
