module MultiDatabase9000
  module ActiveRecordExtensions
    module Schema
      extend ActiveSupport::Concern

      def define(info, &block) # :nodoc:
        instance_eval(&block)

        unless info[:version].blank?
          initialize_schema_migrations_table
          database_match = caller[1].match(/\/(\w+)_schema/)
          if database_match.present?
            connection.assume_migrated_upto_version(info[:version], MultiDatabase9000.migration_path_for(database_match.captures.first))
          else
            connection.assume_migrated_upto_version(info[:version], migrations_paths)
          end
        end
      end
    end
  end
end