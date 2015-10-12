module MultiDatabase9000
  def self.maintain_all_test_schemas! # :nodoc:
    # Roundrip to Rake to allow plugins to hook into database initialization.
    FileUtils.cd Rails.root do
      current_config = ActiveRecord::Base.connection_config
      ActiveRecord::Base.clear_all_connections!
      system("bin/rake db:test:prepare")
      # Establish a new connection, the old database may be gone (db:test:prepare uses purge)
      ActiveRecord::Base.establish_connection(current_config)
    end
  end
end