gemfile_path          = "#{File.basename(__FILE__, '.rb')}.gemfile"
ENV['BUNDLE_GEMFILE'] = File.expand_path(gemfile_path)

unless File.exists?(gemfile_path)
  File.write(gemfile_path, <<-GEMFILE)
    source 'https://rubygems.org'
    gem 'rails', path: '../rails'
    #gem 'rails', '4.0.0'
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
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :users do |_|
  end

  create_table :vendors do |_|
  end

  create_table :links do |t|
    t.integer :user_id
    t.integer :vendor_id
  end
end

class User < ActiveRecord::Base
  has_many :links #, -> { includes(:vendor) }
  has_many :vendors, through: :links
end

class Vendor < ActiveRecord::Base
  has_many :links, -> { includes(:user) }
  has_many :users, through: :links
end

class Link < ActiveRecord::Base
  belongs_to :user
  belongs_to :vendor
end

class BugTest < MiniTest::Unit::TestCase
  def test_has_many_with_scope
    user   = User.create!
    vendor = Vendor.create!

    Link.create!(user: user, vendor: vendor)

    #assert_equal 1, user.relationships.to_a.size
    #assert_equal 1, vendor.relationships.to_a.size
    #
    #assert_equal 1, user.vendors.to_a.size
    p vendor.links.to_sql
    #users = vendor.users
    #assert_equal 1, users.to_a.size
  end
end