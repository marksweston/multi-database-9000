namespace :db do
  task :create => [:load_config] do
    ActiveRecord::Tasks::DatabaseTasks.create_all
  end
end
