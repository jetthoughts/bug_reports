gemfile_path          = "#{File.basename(__FILE__, '.rb')}.gemfile"
ENV['BUNDLE_GEMFILE'] = File.expand_path(gemfile_path)

unless File.exists?(gemfile_path)
  File.write(gemfile_path, <<-GEMFILE)
    source 'https://rubygems.org'
    #gem 'rails', github: 'rails/rails'
    gem 'rails', path: '../rails'
    #gem 'rails', '4.0.1.rc1'
    #gem 'pg'
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
#
#adapter_tasker = ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(database_configuration.stringify_keys)
#adapter_tasker.drop
#adapter_tasker.create


ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :roles, force: true do |t|
  end

  create_table :communications, force: true do |t|
    t.integer :communication_target_id
    t.string :communication_target_type

    t.integer :role_id


    t.string :type
  end
end

class Role < ActiveRecord::Base
  has_many :communications
end

class CompanyRole < Role
  has_many :planned_communications_as_target, as: :communication_target, class_name: 'PlannedCommunication'

  def all_planned_communications_as_target
    PlannedCommunication.where('id in (?)', planned_communications_as_target.select(:id))
  end
end

class Communication < ActiveRecord::Base
  belongs_to :communication_target, polymorphic: true
  belongs_to :role
end

class PlannedCommunication < Communication
end

class TestPolymorphicSubquery < MiniTest::Unit::TestCase
  def test_find_or_create_by_with_build
    role = CompanyRole.create!
    role.planned_communications_as_target.create!

    p role.planned_communications_as_target.where(['id in (?)', [1]]).to_sql
    #p role.planned_communications_as_target.where(id: 1).to_sql
    #p role.planned_communications_as_target.to_sql
    #p CompanyRole.find(1).all_planned_communications_as_target
  end

  def test_simples
    role = Role.create!
    role.communications.create!

    Role.connection.unprepared_statement do
     p role.communications.to_sql
    end

    #p CompanyRole.find(1).all_planned_communications_as_target
  end
end