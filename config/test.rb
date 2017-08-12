
DEFAULT_DB_CONNECTION = 'postgres://wits_user:password@localhost/wits-db'

DB = Sequel.connect(:adapter => 'postgres', :host => 'localhost',:user => 'wits_user', :password => 'password', :database => 'wits-db',
                    :servers_hash=>Hash.new{|h,v| raise Exception.new("Unknown server: #{v}")},
                    :loggers => [])      #[Logger.new($stdout)]

DB.extension :server_logging
DB.extension :pg_json

HOST_URL = 'https://test-url/'.freeze