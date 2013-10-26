unless File.exists?('Gemfile')
  File.write('Gemfile', <<-GEMFILE)
    source 'https://rubygems.org'
    gem 'rails', path: '../rails'
    #gem 'rails', '= 3.2.13'
    #gem 'rails', '= 4.0.0'
    gem 'sqlite3'
  GEMFILE

  system 'bundle'
end

require 'bundler'
Bundler.setup(:default)

require 'active_record'
require 'minitest/autorun'
require 'logger'

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)


ActiveRecord::Schema.define do
  create_table :items do |t|
    t.string 'type'
  end
end

class Item < ActiveRecord::Base
  default_scope { order('type ASC nulls last') }
end

class BugTest < MiniTest::Unit::TestCase
  def test_association_stuff
    assert_includes Item.last.to_sql, 'ORDER BY type DESC nulls last LIMIT 1'
  end
end