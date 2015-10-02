require "multi-database-9000/version"

module MultiDatabase9000
  class Railtie < Rails::Railtie
    rake_tasks do
      load "multi-database-9000/tasks/multi-database-9000_tasks.rake"
    end
  end
end
