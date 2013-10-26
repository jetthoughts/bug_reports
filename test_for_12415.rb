gemfile_path  = "#{File.basename(__FILE__, '.rb')}.gemfile"
ENV['BUNDLE_GEMFILE'] = File.expand_path(gemfile_path)

unless File.exists?(gemfile_path)
  File.write(gemfile_path, <<-GEMFILE)
    source 'https://rubygems.org'
    #gem 'rails', github: 'rails/rails'
    gem 'rails', path: '../rails'
    #gem 'rails', '4.0.0'
    gem 'pg'
    gem 'sqlite3'
  GEMFILE

  system "bundle --gemfile=#{gemfile_path} --clean"
end

require 'bundler'
Bundler.setup(:default)

require 'active_record'
require 'minitest/autorun'
require 'logger'

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
#database_configuration = { adapter: 'postgresql', database: 'rails_issues' }

#adapter_tasker = ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(database_configuration.stringify_keys)
#adapter_tasker.drop
#adapter_tasker.create

ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :blogs, force: true do |t|
  end
end

class Blog < ActiveRecord::Base
end

class TestSubquery < MiniTest::Unit::TestCase
  def test_subquery
    blog = Blog.create!
    # A few different subqueries
    mine  = Blog.where(id: 1)
    #mine  = Blog.where("id > ? AND 'foo'='foo'", 0)

    # subquery as a hash parameter
    query1 = Blog.where(id: mine)
    assert_equal [blog], query1.to_a
    #assert_includes query1.to_sql, "foo"

    # subquery as a regular param
    query2 = Blog.where('id IN (?)', mine) # way to do UNION for now
    assert_equal [blog], query2.to_a
    #assert_includes query2.to_sql, "foo"
  end
end