require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'fileutils'
require 'ostruct'
require 'log_buddy'

require 'rspec'

require 'mm-voteable'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

log_dir = File.expand_path('../../log', __FILE__)
FileUtils.mkdir_p(log_dir) unless File.exist?(log_dir)

logger = Logger.new(log_dir + '/test.log')
LogBuddy.init(:logger => logger)

MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017, :logger => logger)
MongoMapper.database = "mm-test-#{RUBY_VERSION.gsub('.', '-')}"
MongoMapper.database.collections.each { |c| c.drop_indexes }


RSpec.configure do |config|
  
  config.after(:each) do
    MongoMapper.database.collections.collect do |collection|
      unless %w(system.js system.indexes system.users).any? { |name| name == collection.name }
        puts "Dropping #{collection.name}"
        MongoMapper.database.drop_collection(collection.name)
      end
    end
  end
  
end