gemfile_path          = "#{File.basename(__FILE__, '.rb')}.gemfile"
ENV['BUNDLE_GEMFILE'] = File.expand_path(gemfile_path)

unless File.exists?(gemfile_path)
  File.write(gemfile_path, <<-GEMFILE)
    source 'https://rubygems.org'
    gem 'rails', path: '../rails'
    #gem 'rails', '4.0.1.rc1'
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
  create_table :users, force: true do |t|
    t.string :name
  end
end

class User < ActiveRecord::Base
  def name=(name)
    puts "Invoked"
    p caller_locations(1,10)
    super("Super #{name}")
  end
end


class TestDoubleInvokeAssign < MiniTest::Unit::TestCase
  def test_double_assign

    user = User.new(name: 'User')
    assert_equal 'Super User', user.name
    assert_equal 'Super User', User.create(name: 'User').name
  end
end