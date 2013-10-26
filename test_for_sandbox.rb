unless File.exists?('Gemfile')
  File.write('Gemfile', <<-GEMFILE)
    source 'https://rubygems.org'
    #gem 'rails', github: 'rails/rails'
    gem 'rails', path: '../rails'

    gem 'sqlite3'
    #gem 'pg'
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
  create_table :posts do |t|
  end

  create_table :post_comments do |t|
    t.string :title
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments
  has_one :comment, -> { wheCastre(id: 1).where(id: 2)  }, :class_name => 'Comment' # Works
  has_one :comment_as_arel, -> { where(Comment.arel_table[:id].eq(1)).where(id: 2)  }, :class_name => 'Comment' # Works
  has_one :comment_as_arel2, -> { where(Comment.arel_table[:id].gt(1)).where(id: 2)  }, :class_name => 'Comment' # Fails
  has_one :comment_as_string, -> { where("title = ?", 1).where(title: 2)  }, :class_name => 'Comment' # Fails
end

class Post::Comment < ActiveRecord::Base
  belongs_to :post
end

class BugTest < MiniTest::Unit::TestCase
  def test_association_with_conditions_as_symbols
    post = Post.create!
    post.comments << Post::Comment.create!

    assert_equal 0, Post.joins(:comment).count  # Works
  end

end