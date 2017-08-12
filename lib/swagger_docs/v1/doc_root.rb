require 'json'
require 'swagger/blocks'

module V1
  module API
    module Documentation

      class DocRoot
        include Swagger::Blocks

        swagger_root do
          key :swagger, '2.0'

          key :basePath, "/v1"
          key :consumes, ['application/json']
          key :produces, ['application/json']
          info do
            key :title, 'Wits Wagers API Documentation'
            key :version, '1.0.0'
          end
          key :tags, ['players', 'games']
          security_definition :api_token do
            key :type, :apiKey
            key :name, :api_token
            key :in, :query
          end
          security do
            key :api_token, []
          end

        end


      end

    end

  end
end

