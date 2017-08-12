# #require_relative '../contact_base'
#
#
# module Contracts
#   module Responses
#
#     class RequestErrorField < ContractBase
#       field :field, String
#       field :message, String
#
#       swaggify_model
#
#     end
#
#     class BadRequestResponse < ContractBase
#
#       field :errors, Array, :items => RequestErrorField, :default => []
#
#       def initialize
#         self.errors = []
#       end
#
#       swaggify_model
#
#     end
#
#     class BulkRequestErrorField < BadRequestResponse
#       field :request_id, String
#
#       swaggify_model
#
#     end
#
#   end
# end