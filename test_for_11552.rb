unless File.exists?('Gemfile')
  File.write('Gemfile', <<-GEMFILE)
    source 'https://rubygems.org'
    gem 'rails', path: '../rails'
    #gem 'rails', '= 3.2.13'
    #gem 'rails', '= 4.0.0'
    gem 'pg'
  GEMFILE

  system 'bundle'
end

require 'bundler'
Bundler.setup(:default)

require 'active_record'
require 'minitest/autorun'
require 'logger'

database_configuration = { adapter: 'postgresql', database: 'test_115522' }


adapter_tasker = ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(database_configuration.stringify_keys)
adapter_tasker.drop
adapter_tasker.create

ActiveRecord::Base.establish_connection(database_configuration)
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :items do |t|
    t.inet 'ip'
  end
end

class Item < ActiveRecord::Base
end

class BugTest < MiniTest::Unit::TestCase
  def test_association_stuff
    item    = Item.new
    item.ip = 'foo'
  end
end