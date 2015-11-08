module MultiDatabase9000
  def self.maintain_all_test_schemas!
    # Roundrip to Rake to allow plugins to hook into database initialization.
    FileUtils.cd Rails.root do
      current_config = ActiveRecord::Base.connection_config
      ActiveRecord::Base.clear_all_connections!
      system("bin/rake db:test:prepare")
      # Establish a new connection, the old database may be gone (db:test:prepare uses purge)
      ActiveRecord::Base.establish_connection(current_config)
    end
  end

  def self.migration_path_for(database)
    return nil unless database.present?
    return ["db/#{database}_migrate"]
  end

  def database_connections(database: nil, rails_envs: nil)
    connections = connections_for_environment(rails_envs)
    if database.present?
      connections.keep_if {|key, _| key.match Regexp.new(database)}
    end
    return connections
  end

  def connections_for_environment(rails_envs)
    rails_envs = Array(rails_envs)
    matcher = ->(key, value){rails_envs.any?{|env| key.match Regexp.new(env)}}
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
end