
class MultiMigrationGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  argument :database_name, :type => :string, :required => false, :banner => 'DBNAME'
  argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
  
  
  source_root File.expand_path('../templates', __FILE__)
  
  def self.next_migration_number(dirname)
    next_migration_number = current_migration_number(dirname) + 1
    if ActiveRecord::Base.timestamped_migrations
      [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
    else
      SchemaMigration.normalize_migration_number(next_migration_number)
    end
  end

  def create_migration_file
    set_local_assigns!
    migration_template "migration.rb", migration_directory
  end

  def migration_directory
    if (database_name == "default") || database_is_nil?
      "db/migrate/#{file_name}.rb"
    else
      "db/#{database_name.downcase}_migrate/#{file_name}.rb"
    end
  end

  def database_is_nil?
    db_name = database_name
    return true if db_name.nil?
  end
  
  protected

  attr_reader :migration_action

  def set_local_assigns!
    if file_name =~ /^(add|remove)_.*_(?:to|from)_(.*)/
      @migration_action = $1
      @table_name       = $2.pluralize
    end
  end
end


