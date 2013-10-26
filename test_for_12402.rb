gem 'activerecord', '4.0.0'
require 'active_record'
require 'minitest/autorun'
require 'logger'

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :email_address
  end
end

class User < ActiveRecord::Base
  alias_attribute :email, :email_address

  validates_uniqueness_of :email
end

class BugTest < MiniTest::Unit::TestCase
  def test_validations_for_aliased_columns
    user = User.new(email: 'aloha@ruby.com')

    assert_equal true, user.valid?
  end
end