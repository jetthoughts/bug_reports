# Activate the gem you are reporting the issue against.
unless File.exists?('Gemfile')
  File.write('Gemfile', <<-GEMFILE)
    source 'https://rubygems.org'
    gem 'rails', path: '../rails'
    gem 'sqlite3'
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

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts do |t|
  end

  create_table :comments do |t|
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class BugTest < MiniTest::Unit::TestCase
  def test_association_stuff
    p Post.order(:id).to_sql
    p Post.order(id: :asc).to_sql
    assert_equal Post.order(:id).to_sql, Post.order(id: :asc).to_sql
  end
end