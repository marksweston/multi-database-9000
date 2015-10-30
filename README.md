# MultiDatabase9000

A plugin designed to help a Rails app work transparently with multiple databases, inspired by the multi-database-migrations
gem (which was immensely helpful when we started down this road). But in the process of updating that gem to work with Rails 4,
we decided that we preferred an API that allowed us to transparently use the Rails and Rake commands we already knew
rather than create new versions within a separate namespace.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'multi-database-9000'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install multi-database-9000

## Concept

The gem assumes that your app has a "default" or "main" database that's configured in the standard test, development
and production connections defined in database.yml. Also that there are one or more extra databases configured with connection
 names that start with a name for that database followed by the environment name (e.g. if you had a database called "widgets" you
 would have connections defined for widgets_test, widgets_development and widgets_production). The name used in the connection
 does not have to match the actual database name, but does need to be used consistently to refer to that database (e.g.
 if I use the name "widgets" in database.yml I also need to use it when creating a directory for migrations).

## Usage

### Database Connections
Create a new set of connections for your database in database.yml, in the form of "*database_name*_test",
"*database_name*_production" etc.

Create a new directory under db/ called *database_name*_migrate to hold migrations for the database.

### The Multi Migration command
Create a new migration with "rails generate multi_migration *migration* *database_name*". The *database_name* is 'default' for your default or original database (this can also be left off for the default database only and the migration will still work), otherwise it is the name of the database you wish to migrate to e.g. "rails generate multi_migration AddTitleToWidgets widgets".

If you wish to use multi-database-9000 in a single database app, the command 'rails generate migration CreateWidgetsTable' will still work.

### Rake Tasks
"rake db:create" will attempt to create all databases for all connections.  
"rake db:create DATABASE=widgets" will only create databases for connections with "widget" in their name.

Similarly, "rake db:schema:load" and "rake db:schema:dump" will load or dump schemas for all connections to all databases.
"rake db:schema:load DATABASE=widget" will only load the schema for databases in connections with "widget" in their name.

### Database Schema
In order for test database schemas to be kept updated, add the following line to your `test_helper` or `spec_helper` files:

    MultiDatabase9000.maintain_all_test_schemas!

## Contributing

1. Fork it ( https://github.com/[my-github-username]/multi-database-9000/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
