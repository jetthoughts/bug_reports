# Activate the gem you are reporting the issue against.
gemfile_path  = "#{File.basename(__FILE__, '.rb')}.gemfile"
ENV['BUNDLE_GEMFILE'] = File.expand_path(gemfile_path)


unless File.exists?(gemfile_path)
  File.write(gemfile_path, <<-GEMFILE)
    source 'http://rubygems.org'
    gem 'rails', github: 'rails/rails', branch: '4-0-stable'
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

  create_table :issues do |t|
    t.string :name
    t.integer :current_version_id

    t.timestamps
  end

  create_table :versions do |t|
    t.integer :issue_id

    t.timestamps
  end
end

class Version < ActiveRecord::Base
  belongs_to :issue

  after_create :set_current_version

  private

  def set_current_version
    issue.update_column(:current_version_id, id) unless issue.current_version
  end
end

class Issue < ActiveRecord::Base
  has_many :versions, dependent: :destroy, inverse_of: :issue
  belongs_to :current_version, class_name: 'Version'

  before_save :create_version

  private

  def create_version
    versions.build
  end
end

class BugTest <  MiniTest::Unit::TestCase
  def test_association_with_conditions_as_symbols
    #Issue.where(name: 'omg').create!

    #Issue.where('"issues"."name" = "omg"').create!
    Issue.where("`issues`.`name` = \"omg\"").create!
  end

end