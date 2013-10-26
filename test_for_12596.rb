gemfile_path          = "#{File.basename(__FILE__, '.rb')}.gemfile"
ENV['BUNDLE_GEMFILE'] = File.expand_path(gemfile_path)

unless File.exists?(gemfile_path)
  File.write(gemfile_path, <<-GEMFILE)
    source 'https://rubygems.org'
    #gem 'rails', github: 'rails/rails'
    gem 'rails', path: '../rails'
    #gem 'rails', '4.0.1.rc1'
    #gem 'pg'
  GEMFILE

  system "bundle --gemfile=#{gemfile_path} --clean"
end

require 'bundler'
Bundler.setup(:default)

require 'active_support/time'
require 'minitest/autorun'
require 'logger'


class TestTimezone < MiniTest::Unit::TestCase
  def test_round_reset_timezone
    Time.zone = 'Europe/Paris'
    assert_equal 'CEST', (t1 = Time.zone.parse('2013-10-27 02:30:00')).zone

    p t2 = t1 + 1.hour

    assert_equal 'CET', t2.zone
    round_t2 = t2.round
    assert_equal 'CET', round_t2.zone
  end
end