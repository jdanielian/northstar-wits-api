ENV['RACK_ENV'] ||= 'development'

CURRENT_ENV = ENV['RACK_ENV']

require 'logger'
require_relative '../lib/simple_logger'
require 'sequel'
require_relative './' + CURRENT_ENV

