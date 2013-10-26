gemfile_path          = "#{File.basename(__FILE__, '.rb')}.gemfile"
ENV['BUNDLE_GEMFILE'] = File.expand_path(gemfile_path)

unless File.exists?(gemfile_path)
  File.write(gemfile_path, <<-GEMFILE)
    source 'https://rubygems.org'
    gem 'rails', '4.0.1.rc1'
    gem 'sqlite3'
  GEMFILE

  system "bundle --gemfile=#{gemfile_path} --clean"
end

require 'bundler'
Bundler.setup(:default)

require 'active_record'
require 'minitest/autorun'
require 'logger'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :sites, force: true do |t|
    t.string :repo
    t.string :env
    t.integer :build, default: 0, null: false
  end
end

class Site < ActiveRecord::Base
  BUILD = { manual: 0, cap: 1, recap: 2 }

  def build
    BUILD.key(read_attribute(:build))
  end

  def build=(b)
    write_attribute(:build, BUILD[b])
  end
end

class TestBuildSymbol < MiniTest::Unit::TestCase
  def test_find_or_create_by_with_build
    Site.find_or_create_by(repo: 'bob', env: 'staging', build: :recap)
    Site.find_or_create_by(repo: 'joe', env: 'staging', build: :manual)
    Site.find_or_create_by(repo: 'jim', env: 'staging', build: :manual)
    assert_equal 3, Site.count

    ### This is the temporary fix, to use the integer values... doesn't fail ###
    Site.find_or_create_by(repo: 'joe', env: 'staging', build: 0)
    Site.find_or_create_by(repo: 'bob', env: 'staging', build: 2)
    assert_equal 3, Site.count

    ### The following does fail though and duplicates the exact some entries in the DB ###
    Site.find_or_create_by(repo: 'joe', env: 'staging', build: :manual)
    Site.find_or_create_by(repo: 'bob', env: 'staging', build: :recap)
    assert_equal 3, Site.count
  end
end