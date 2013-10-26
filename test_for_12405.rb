gemfile_path  = "#{File.basename(__FILE__, '.rb')}.gemfile"
ENV['BUNDLE_GEMFILE'] = File.expand_path(gemfile_path)

unless File.exists?(gemfile_path)
  File.write(gemfile_path, <<-GEMFILE)
    source 'https://rubygems.org'
    #gem 'rails', github: 'rails/rails'
    gem 'rails', path: '../rails'
    #gem 'rails', '4.0.0'
    gem 'pg'
  GEMFILE

  system "bundle --gemfile=#{gemfile_path} --clean"
end

require 'bundler'
Bundler.setup(:default)

require 'active_record'
require 'minitest/autorun'
require 'logger'

database_configuration = { adapter: 'postgresql', database: 'rails_issues' }

#adapter_tasker = ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(database_configuration.stringify_keys)
#adapter_tasker.drop
#adapter_tasker.create

ActiveRecord::Base.establish_connection(database_configuration)

ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end

  create_table :comments, force: true do |t|
    t.references :post
    t.timestamps
  end
end

class Post < ActiveRecord::Base
  has_many :comments, -> { uniq }
end

class Comment < ActiveRecord::Base
  belongs_to :post

  default_scope -> { order('comments.created_at') }
end

class BugTest < MiniTest::Unit::TestCase
  def test_includes_with_default_scope
    comment = Comment.create!(post: Post.create!)
    comments = Post.first.comments
    comments.reorder(nil).include?(comment)
  end
end