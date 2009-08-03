require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'ip_geolocation'

desc 'Test the ip_geolocation plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'profile'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

