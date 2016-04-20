
def database_connections(database: nil, rails_envs: nil)
  connections = connections_for_environment(rails_envs)
  if database.present?
    connections.keep_if {|key, _| key.match Regexp.new(database)}
  end
  return connections
end

def connections_for_environment(*rails_envs, include_default_env: true)
  rails_envs = Array(rails_envs)
  matcher = ->(key, _){rails_envs.any?{|env| key.match(Regexp.new(env)) && (include_default_env || env != key)}}
  puts ActiveRecord::Base.configurations.keep_if(&matcher)
  return ActiveRecord::Base.configurations.keep_if &matcher
end

def database_name(connection_key)
  if connection_key.match /\w+_\w+/
    return connection_key.split('_').first
  else
    return "default"
  end
end

def migration_directory(connection_key)
  if ['test','development','staging','cucumber','production'].include? connection_key
    return "db/migrate/"
  else
    return "db/#{database_name(connection_key)}_migrate/"
  end
end

def schema_file_name(connection_key)
  if ['test','development','staging','cucumber','production'].include? connection_key
    return "schema.rb"
  else
    return "#{database_name(connection_key)}_schema.rb"
  end
end

Rake::Task['db:create'].clear
Rake::Task['db:migrate'].clear
Rake::Task['db:schema:dump'].clear
Rake::Task['db:schema:load'].clear
Rake::Task['db:migrate:status'].clear

Rake::Task["db:test:load_schema"].enhance do
  begin
    should_reconnect = ActiveRecord::Base.connection_pool.active_connection?
    connections_for_environment("test", include_default_env: false).each do |connection_key, connection|
      ActiveRecord::Tasks::DatabaseTasks.load_schema_for connection, :ruby, "db/#{schema_file_name(connection_key)}"
    end
  ensure
    if should_reconnect
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[ActiveRecord::Tasks::DatabaseTasks.env])
    end
  end
end

Rake::Task["db:test:purge"].enhance do
  connections_for_environment("test", include_default_env: false).values.each do |connection|
    ActiveRecord::Tasks::DatabaseTasks.purge connection
  end
end

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

  namespace :migrate do
    desc 'Display status of migrations'
    task :status => [:environment] do
      migrations_list = []

      database_connections(:database => ENV["DATABASE"], :rails_envs => "development" || ENV["RAILS_ENV"]).keys.each do |connection_key|
        ActiveRecord::Base.establish_connection(connection_key)

        abort 'Schema migrations table does not exist yet.' unless ActiveRecord::SchemaMigration.table_exists?

        db_list = ActiveRecord::SchemaMigration.normalized_versions

        file_list =
            Dir.foreach(migration_directory(connection_key)).grep(/^(\d{3,})_(.+)\.rb$/) do
              version = ActiveRecord::SchemaMigration.normalize_migration_number($1)
              status = db_list.delete(version) ? 'up' : 'down'
              [status, version, database_name(connection_key), $2.humanize]
            end

        db_list.map! do |version|
          ['up', version, database_name(connection_key), '********** NO FILE **********']
        end

        migrations_list += db_list + file_list
      end

      # output
      puts "#{'Status'.center(8)}  #{'Migration ID'.ljust(14)}  #{'Database'.ljust(14)}  Migration Name"
      puts "-" * 50
      (migrations_list).sort_by { |_, version, _, _| version }.each do |status, version, database, name|
        puts "#{status.center(8)}  #{version.ljust(14)}  #{database.ljust(14)}  #{name}"
      end
      puts
    end
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
      database_connections(:database => ENV["DATABASE"], :rails_envs => rails_envs).keys.each do |connection_key|
        ActiveRecord::Base.establish_connection(connection_key)
        filename = ENV['SCHEMA'] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, schema_file_name(connection_key))
        File.open(filename, "w:utf-8") do |file|
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      end
      db_namespace['schema:dump'].reenable
    end

    desc 'Load a schema.rb file into the database'
    task :load => [:environment, :load_config] do
      database_connections(:database => ENV["DATABASE"], :rails_envs => ENV["RAILS_ENV"] || "development").each do |connection_key, connection|
        ActiveRecord::Tasks::DatabaseTasks.load_schema_for connection, :ruby, "db/#{schema_file_name(connection_key)}"
      end
    end
  end
end
