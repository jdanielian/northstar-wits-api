source 'https://rubygems.org'

gem 'rake'
gem 'sequel', '~> 4.43'
gem 'swagger-blocks', '~> 2.0'
# non rubygems hosted gems that the platform gem has, NEED to be explicitly specified here
gem 'icss-activesupport-4', '~> 0.4.0'
gem 'roda-message_bus', '~> 1.0'
gem "erubis"
gem "tilt"



platforms :jruby do
  # use headius version of gem
  gem 'jruby-pg', '~> 0.1'
end

platforms :mri do
  gem 'pg', '~> 0.19.0', :platform => :mri
end

platforms :jruby do
  gem 'torquebox-web', '4.0.0.beta3'
end

group :test, :development do
  gem 'rspec', '~> 3.1.0'
  gem 'simplecov', require: false
  gem 'faker' , '~> 1.7'
  gem 'rack-test', require: 'rack/test'
  gem 'json_spec'

end

group :development do
  gem 'puma'
  gem 'guard', '~> 2.6.1'
  gem 'guard-rspec', '~> 4.3.1', require: false
end
