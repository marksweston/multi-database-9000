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

def migration_directory connection_key
  if ['test','development','staging','cucumber','production'].include? connection_key
    database_name = 'default'
  else
    database_name = connection_key.split('_')[0]
  end
  if database_name == "default"
    return "db/migrate/"
  else
    return "db/#{database_name}_migrate/"
  end

end

Rake::Task['db:create'].clear
Rake::Task['db:migrate'].clear

namespace :db do
  desc "Creates all databases from config/database.yml, or the database specified by DATABASE for the current RAILS_ENV"
  task :create => [:load_config] do
    database_connections(:database => ENV["DATABASE"], :rails_env => ENV["RAILS_ENV"]).values.each do |database_connection|
      ActiveRecord::Tasks::DatabaseTasks.create database_connection
    end
  end

  task :migrate => :environment do
    rails_env = ENV["RAILS_ENV"] || "development"
    database_connections(:database => ENV["DATABASE"], :rails_env => rails_env).each do |connection_key , database_connection|
      ActiveRecord::Base.establish_connection(connection_key)
      ActiveRecord::Migrator.migrate(migration_directory(connection_key) , ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end
  end
end
