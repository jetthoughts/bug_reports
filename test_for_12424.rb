# Activate the gem you are reporting the issue against.
unless File.exists?('Gemfile')
  File.write('Gemfile', <<-GEMFILE)
    source 'https://rubygems.org'
    gem 'rails', '4.0.0'
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
  create_table :coupons do |t|
    t.string :name
  end
end

class Product < ActiveRecord::Base
end

class Coupon < ActiveRecord::Base
  def self.default_scope
    where(name: 'Adrien')
  end
end

class BugTest < MiniTest::Unit::TestCase
  def test_association_with_conditions_as_symbols
    assert_equal 'Adrien', Coupon.new.name
    assert_equal 'Adrien', Coupon::create!.name
  end
end