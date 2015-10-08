require 'pry'

def database_connections(database: nil, rails_envs: nil)
  connections = connections_for_environment(rails_envs)
  if database.present?
    connections.keep_if {|key, value| key.match Regexp.new(database)}
  end
  return connections
end

def connections_for_environment(rails_envs)
  rails_envs = Array(rails_envs)
  matcher = ->(key, value){rails_envs.any?{|env| key.match Regexp.new(env)}}
  return ActiveRecord::Base.configurations.keep_if &matcher
end

def migration_directory(connection_key)
  if ['test','development','staging','cucumber','production'].include? connection_key
    return "db/migrate/"
  else
    database_name = connection_key.split('_')[0]
    return "db/#{database_name}_migrate/"
  end
end

Rake::Task['db:create'].clear
Rake::Task['db:migrate'].clear

db_namespace = namespace :db do
  desc "Creates all databases from config/database.yml, or the database specified by DATABASE for the current RAILS_ENV"
  task :create => [:load_config] do
    if ENV["RAILS_ENV"] == "development" || ENV["RAILS_ENV"].nil?
      rails_envs = ["development", "test"]
    else
      rails_envs = ENV["RAILS_ENV"]
    end
    database_connections(:database => ENV["DATABASE"], :rails_envs => rails_envs).values.each do |database_connection|
      ActiveRecord::Tasks::DatabaseTasks.create database_connection
    end
  end

  task :migrate => :environment do
    rails_env = ENV["RAILS_ENV"] || "development"
    database_connections(:database => ENV["DATABASE"], :rails_envs => rails_env).keys.each do |connection_key|
      ActiveRecord::Base.establish_connection(connection_key)
      ActiveRecord::Migrator.migrate(migration_directory(connection_key) , ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end
    db_namespace['_dump'].invoke
  end

  namespace :schema do
    desc 'Create a db/schema.rb file for each database, that is portable against any DB supported by AR'
    task :dump => [:environment] do
      require 'active_record/schema_dumper'

      if ENV["RAILS_ENV"] == "development" || ENV["RAILS_ENV"].nil?
        rails_envs = ["development", "test"]
      else
        rails_envs = ENV["RAILS_ENV"]
      end
      database_connections(:database => ENV["DATABASE"], :rails_envs => rails_envs).each do |connection_key, database_connection|
        ActiveRecord::Base.establish_connection(connection_key)
        filename = ENV['SCHEMA'] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, 'schema.rb')
        File.open(filename, "w:utf-8") do |file|
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      end
      db_namespace['schema:dump'].reenable
    end
  end
end
