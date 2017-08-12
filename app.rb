require 'json'
require 'roda'
require 'tilt/erubis'
require_relative './config/config'
require_relative 'models'
require 'message_bus'

MessageBus.configure(:backend=>:memory)

class App < Roda
  # plugin :default_headers,
  #        'Content-Type'=>'application/json',
  #        #'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
  #        'X-Frame-Options'=>'deny',
  #        'X-Content-Type-Options'=>'nosniff',
  #        'X-XSS-Protection'=>'1; mode=block'
  #
   plugin :multi_route
   plugin :json
   plugin :render, :escape=>true
   plugin :message_bus
  # plugin :all_verbs
  # plugin :shared_vars

  #plugin :halt



  Dir[File.dirname(__FILE__) + '/routes/**/*.rb'].each {|file| require file }



  route do |r|
    r.multi_route


    r.on "v1" do

      r.on "games" do

      end

      r.on "apidocs" do
        #r.run V1::API::SwaggerDocs
      end

    end

    r.on 'games' do

      r.on 'publish' do

        r.message_bus('/games/publish')

        r.post 'answers' do
          MessageBus.publish('/games/publish', '{"blah":"yes"}')

          ''
        end



      end


    end





    r.on 'health' do
      {:version => 1}
    end

  end
end