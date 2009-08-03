require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'tempfile'

gem 'sqlite3-ruby'

require 'active_record'
require 'active_support'
begin
  require 'ruby-debug'
rescue LoadError
  puts "ruby-debug not loaded"
end

ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
RAILS_ENV  = "test"

$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'lib', 'ip_geolocation')

require File.join(ROOT, 'lib', 'ip_geolocation.rb')

FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures")
config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])

# DB schema
ActiveRecord::Migration.verbose = false
load(File.join(File.join(File.dirname(__FILE__), '.'), "schema.rb"))

def assert_false(conditions, message="")
  assert_equal false, conditions, message
end

def assert_true(conditions, message="")
  assert_equal true, conditions, message
end