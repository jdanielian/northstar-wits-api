#
#
# module V1
#   module API
#
#     class SwaggerDocs < Roda
#       include Contracts::Responses
#       include Contracts::Requests
#       extend Contracts::JsonParserErrorHandler
#
#       plugin :json,  classes: [Array, Hash]
#       plugin :all_verbs
#       plugin :slash_path_empty
#       plugin :json_parser, :error_handler => parser_response
#       plugin :shared_vars
#       plugin :halt
#       plugin :dto_parser
#       plugin :request_headers
#       plugin :caching

#
#       @@static_classes ||= [V1::API::Documentation::DocRoot]
#       @@swagger_classes ||= @@static_classes + ......get_swaggified_models
#
#
#       route do |r|
#
#         r.get do
#           Swagger::Blocks.build_root_json(@@swagger_classes)
#         end
#
#       end
#
#
#     end
#   end
# end