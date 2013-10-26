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
  create_table :products do |t|
  end

  create_table :coupons do |t|
    t.string :type
  end

  create_table :coupons_coupons do |t|
    t.integer :product_id
    t.integer :subject_product_id
  end

end

class Product < ActiveRecord::Base
end

class Coupon < ActiveRecord::Base
end

class Coupon::Product < Coupon
  has_and_belongs_to_many :products, association_foreign_key: :subject_product_id
end

class BugTest < MiniTest::Unit::TestCase
  def test_association_with_conditions_as_symbols
    Coupon::Product.create!.products
  end

end