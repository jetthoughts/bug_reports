# Activate the gem you are reporting the issue against.
unless File.exists?('Gemfile')
  File.write('Gemfile', <<-GEMFILE)
    source 'https://rubygems.org'
    #gem 'rails', path: '../rails'
    gem 'sqlite3'
    #gem 'rails', '= 3.2.13'
    gem 'rails', '= 4.0.0'
    #gem 'pg'
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
    t.string :name
    t.timestamps
  end
end

class Item < ActiveRecord::Base
  before_create do
    p changes
  end

  before_update do
    p changes
    @before_update_changed = changed
  end

  attr_reader :before_update_changed
end

class ItemTest < MiniTest::Unit::TestCase
  def setup
    puts :create
    @item = Item.create!
    puts :update
    @item.update(name: 'new name')
  end

  def test_changed
    assert_includes @item.before_update_changed, 'name'
    refute_includes @item.before_update_changed, 'updated_at'
  end
end