gemfile_path  = "#{File.basename(__FILE__, '.rb')}.gemfile"
ENV['BUNDLE_GEMFILE'] = File.expand_path(gemfile_path)

unless File.exists?(gemfile_path)
  File.write(gemfile_path, <<-GEMFILE)
    source 'https://rubygems.org'
    gem 'rails', path: '../rails'
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
  create_table :plans do |t|
    t.timestamps
  end

  create_table :programs do |t|
    t.references :plan
  end
end

class Plan < ActiveRecord::Base
  default_scope -> { where('plans.created_at > 1') }
end

class Program < ActiveRecord::Base
  belongs_to :plan
end

class BugTest < MiniTest::Unit::TestCase
  def test_default_scope_for_association
    Program.create! plan: Plan.create!

    p Program.first.plan
  end
end