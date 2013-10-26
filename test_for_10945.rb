gemfile_path          = "#{File.basename(__FILE__, '.rb')}.gemfile"
ENV['BUNDLE_GEMFILE'] = File.expand_path(gemfile_path)

unless File.exists?(gemfile_path)
  File.write(gemfile_path, <<-GEMFILE)
    source 'https://rubygems.org'
    gem 'rails', path: '../rails'
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

require 'active_support/core_ext/name_error'

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :artists do |t|
  end

  create_table :tracks do |t|
  end

  create_table :artistic_roles do |t|
  end

  create_table :artists_tracks do |t|
    t.integer :artist_id
    t.integer :track_id
    t.integer :artistic_role_id
  end
end

class Track < ActiveRecord::Base
  has_many :artists_tracks
  has_many :owning_artists,
    -> { where(artistic_role_id: 1) }, through: :artists_tracks, source: :artist
end

class ArtistsTrack < ActiveRecord::Base
  belongs_to :artist
  belongs_to :track
  belongs_to :artistic_role
end

class Artist < ActiveRecord::Base
  has_many :artists_tracks
  has_many :tracks, through: :artists_tracks
end

class ArtisticRole < ActiveRecord::Base
  has_many :artist_tracks
  has_many :tracks, through: :artists_tracks
  has_many :artists, through: :artists_tracks
end

class ScopeTest < MiniTest::Unit::TestCase
  def test_scoped_finding
    assert_equal 1, Track.first.owning_artists.count
  end

  def test_scoped_creation
    owning_artists = Track.create!.owning_artists
    owning_artists.create!

    assert_equal 1, ArtistsTrack.last.artistic_role_id

    #Track.create!(owning_artist_ids: [1])
    #assert_equal 2, Track.count
    #assert_equal 1, Track.last.owning_artist_ids.length
    #assert_equal 1, Track.last.owning_artist_ids.first
  end
end