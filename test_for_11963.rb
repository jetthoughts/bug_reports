unless File.exists?('Gemfile')
  File.write('Gemfile', <<-GEMFILE)
    source 'https://rubygems.org'
    #gem 'rails', github: 'rails/rails'
    gem 'rails', path: '../rails'

    #gem 'sqlite3'
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
#ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
database_configuration = { adapter: 'postgresql', database: 'test_115522' }

adapter_tasker = ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(database_configuration.stringify_keys)
adapter_tasker.drop
adapter_tasker.create


ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts do |t|
  end

  create_table :comments do |t|
    t.string :title
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments
  has_one :comment, -> { where(id: 1).where(id: 2)  }, :class_name => 'Comment' # Works
  has_one :comment_as_arel, -> { where(Comment.arel_table[:id].eq(1)).where(id: 2)  }, :class_name => 'Comment' # Works
  has_one :comment_as_arel2, -> { where(Comment.arel_table[:id].gt(1)).where(id: 2)  }, :class_name => 'Comment' # Fails
  has_one :comment_as_string, -> { where("title = ?", 1).where(title: 2)  }, :class_name => 'Comment' # Fails
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class BugTest < MiniTest::Unit::TestCase
  def test_association_with_conditions_as_symbols
    post = Post.create!
    post.comments << Comment.create!

    assert_equal 0, Post.joins(:comment).count  # Works
  end

  def test_association_with_conditions_as_arel_equals
    post = Post.create!
    post.comments << Comment.create!

    assert_equal 0, Post.joins(:comment_as_arel).count # Works
  end

  def test_association_with_conditions_as_arel_greater
    post = Post.create!
    post.comments << Comment.create!

    assert_equal 0, Post.joins(:comment_as_arel2).count # Fails
  end

  def test_association_with_conditions_as_string
    post = Post.create!
    post.comments << Comment.create!

    assert_equal 0, Post.joins(:comment_as_string).count # Fails
  end

  def test_duplicated_conditions_as_string
    assert_equal 0, Comment.where("id = ?", 1).where(id: 2).count
    assert_equal 0, Comment.where("title = ?", '1').where(title: '2').count
  end
end