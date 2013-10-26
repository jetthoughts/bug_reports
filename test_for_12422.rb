gemfile_path  = "#{File.basename(__FILE__, '.rb')}.gemfile"
ENV['BUNDLE_GEMFILE'] = File.expand_path(gemfile_path)

unless File.exists?(gemfile_path)
  File.write(gemfile_path, <<-GEMFILE)
    source 'https://rubygems.org'
    #gem 'rails', github: 'rails/rails'
    gem 'rails', path: '../rails'
    #gem 'rails', '4.0.0'
    gem 'pg'
  GEMFILE

  system "bundle --gemfile=#{gemfile_path} --clean"
end

require 'bundler'
Bundler.setup(:default)

require 'active_record'
require 'minitest/autorun'
require 'logger'

# This connection will do for database-independent bug reports.
#ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
database_configuration = { adapter: 'postgresql', database: 'rails_issues' }

adapter_tasker = ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(database_configuration.stringify_keys)
adapter_tasker.drop
adapter_tasker.create

ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts do |t|
    t.timestamps
  end
end

class Post < ActiveRecord::Base
end

class BugTest < MiniTest::Unit::TestCase
  def test_lost_milliseconds
    Post.create!
    Post.first.updated_at.iso8601(3)
  end
end