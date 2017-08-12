# require 'securerandom'
# require 'active_support/core_ext/hash/compact'
#
# module V1
#   module API
#
#     class Subscriptions < Roda
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
#       plugin :app_logger
#       plugin :error_handler do |e|
#
#         error_string = "error is #{e.to_s}, error backtrace => #{e.backtrace.join("\n\t")}"
#         log.error("error in request #{self.request.path}")
#         log.error(error_string)
#         {"errors" => [{"field" =>"server", "message" => "Internal error occurred."}]}
#       end
#
#
#       route do |r|
#
#
#
#         r.post do
#
#         end
#
#
#
#       end
#
#
#     end
#
#
#   end
# end

