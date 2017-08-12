require 'json'
require 'swagger/blocks'

module V1
  module API
    module Documentation

      class ContactsDoc
        include Swagger::Blocks

          swagger_path '/owners/{owner_id}/contacts' do

            operation :post do
              key :tags, ['contacts']
              key :summary, 'Simple create endpoint for persisting an owners contacts'

              parameter do
                key :in, :path
                key :name, :owner_id
                key :description, 'owner_id of contacts'
                key :required, true
                key :type, :string
              end

              parameter do
                key :type, :body
                key :name, :body
                key :in, :body
                key :description, 'POST body for the request. Will persist a contact on success, and return 201 with Location header where to find it'
                key :required, true
                schema do
                  key :'$ref', :'Contracts::Requests::ContactCreateRequest'
                end
              end

              response 400 do
                key :description, 'Invalid request'
              end
              response 201 do
                key :message, 'Created'
                key :description, 'returned when contact is successfully created'
                header :Location do
                  key :type, :string
                  key :description, 'will be a URI of where to get the newly created resource'
                end

              end
            end
          end

        swagger_path '/owners/{owner_id}/contacts/count' do
          operation :post do
            key :tags, ['contacts']
            key :summary, 'Get a count of the owners contacts'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of contacts'
              key :required, true
              key :type, :string
            end

            parameter do
              key :type, :body
              key :name, :body
              key :in, :body
              key :description, 'POST body of search items to filter the result set.'
              key :required, true
              schema do
                key :'$ref', :'Contracts::Requests::ContactSearchCreateRequest'
              end
            end

            response 400 do
              key :description, 'Invalid request'
            end
            response 200 do
              key :description, 'includes the contact count'
              schema do
                key :'$ref', :'Contracts::Responses::ContactCountResponse'
              end

            end
          end
        end

        swagger_path '/owners/{owner_id}/contacts/{contact_id}' do
          operation :get do
            key :tags, ['contacts']
            key :summary, 'Get a specific contact by given contact_id'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of contacts'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :path
              key :name, :contact_id
              key :description, 'contact_id of contact'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :header
              key :name, :'If-None-Match'
              key :type, :string
              key :description, 'can be set to the ETag value of the contact (if fetched previously). Will return 304 if the ETag provided is latest/matching of the persisted contact'
            end

            response 400 do
              key :description, 'Invalid request'
            end
            response 304 do
              key :description, 'Returned when ETag in the If-None-Match header is same as persisted contact'
            end
            response 200 do
              key :description, 'returns the contact object'
              schema do
                key :'$ref', :'Contracts::Responses::ContactResponse'
              end
              header :ETag do
                key :type, :string
                key :description, 'ETag value of the contact, can be used with If-Match on update'
              end
            end
          end
        end

        swagger_path '/owners/{owner_id}/contacts/{contact_id}' do
          operation :put do
            key :tags, ['contacts']
            key :summary, 'Update a specific contact by given contact_id. If-Match header must be supplied with matching ETag for update to succeed.'


            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of contacts'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :path
              key :name, :contact_id
              key :description, 'contact_id of contact'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :header
              key :type, :string
              key :name, :'If-Match'
              key :required, true
              key :description, 'set to the ETag of the contact. If ETag value matches the stored contact, the PUT will succeed.'
            end

            parameter do
              key :type, :body
              key :name, :body
              key :in, :body
              key :description, 'PUT body for the request. Will persist a contact update on success, and return 201 with Location header where to find it'
              key :required, true
              schema do
                key :'$ref', :'Contracts::Requests::ContactUpdateRequest'
              end
            end

            response 400 do
              key :description, 'Invalid request'
            end
            response 404 do
              key :description, 'contact_id not found'
            end
            response 412 do
              key :description, 'ETag supplied doesnt match the latest ETag value of the contact, update is rejected due to version conflict.'
            end
            response 204 do
              key :description, 'on successful update returns Location header to the full resource'

              header :ETag do
                key :type, :string
                key :description, 'ETag value of the contact, can be used with If-Match on update'
              end
              header :'Location' do
                key :type, :string
                key :description, 'Location header to get updated resource'
              end
            end
          end
        end

        swagger_path '/owners/{owner_id}/contacts/{contact_id}' do
          operation :delete do
            key :tags, ['contacts']
            key :summary, 'Delete a specific contact by contact_id'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of contacts'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :path
              key :name, :contact_id
              key :description, 'contact_id of contact'
              key :required, true
              key :type, :string
            end

            response 400 do
              key :description, 'Invalid request'
            end
            response 404 do
              key :description, 'contact_id not found'
            end

            response 204 do
              key :description, 'will be returned when contact is successfully deleted'
            end
          end
        end

        swagger_path '/owners/{owner_id}/contacts/search' do
          operation :post do
            key :tags, ['contacts']
            key :summary, 'search for contacts by specific criteria. '

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of contacts'
              key :required, true
              key :type, :string
            end

            parameter do
              key :type, :body
              key :name, :body
              key :in, :body
              key :description, 'POST body of search items to filter the result set.'
              key :required, true
              schema do
                key :'$ref', :'Contracts::Requests::ContactSearchCreateRequest'
              end
            end

            parameter do
              key :in, :query
              key :name, :page
              key :required, false
              key :description, 'page to fetch (1 based)'
              key :type, :integer
            end

            parameter do
              key :in, :query
              key :name, :page_size
              key :required, false
              key :description, 'page size'
              key :type, :integer
            end

            parameter do
              key :in, :query
              key :name, :sort_by
              key :required, false
              key :description, 'field to sort on. valid values are last_name, first_name, id'
              key :type, :string
            end

            parameter do
              key :in, :query
              key :name, :sort_direction
              key :required, false
              key :description, 'direction to sort, either asc or desc'
              key :type, :string
            end

            parameter do
              key :in, :query
              key :name, 'fields'
              key :required, false
              key :description, 'comma separated list of field names to restrict the payload to (an optimization). valid values are: id unified_id external_id source_id name.first_name name.last_name title_info.title title_info.job_department title_info.job_level phone_numbers.work emails.work etag last_modified created_on tags company.name linkedin_url'
              key :type, :string
            end

            response 400 do
              key :description, 'Invalid request'
            end

            response 200 do
              key :description, 'will be returned  with search results'
              schema do
                key :'$ref', :'Contracts::Responses::ContactSearchResponse'
              end
            end
          end
        end

        swagger_path '/owners/{owner_id}/contacts/search/cache' do
          operation :post do
            key :tags, ['contacts']
            key :summary, 'create cached search for contacts with specified criteria.'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of contacts'
              key :required, true
              key :type, :string
            end

            parameter do
              key :type, :body
              key :name, :body
              key :in, :body
              key :description, 'POST body of search items to filter the result set.'
              key :required, true
              schema do
                key :'$ref', :'Contracts::Requests::ContactSearchCreateRequest'
              end
            end

            response 400 do
              key :description, 'Invalid request'
            end

            response 201 do
              key :description, 'will be returned  with search results'

              header :'Location' do
                key :type, :string
                key :description, 'Location header to get the actual list of cached contacts'
              end

              header :'X-Total-Count' do
                key :type, :string
                key :description, 'Custom header that has the total number of contacts just saved to the cache'
              end

            end
          end
        end

        swagger_path '/owners/{owner_id}/contacts/search/cache/{cache_id}' do
          operation :get do
            key :tags, ['contacts']
            key :summary, 'create cached search for contacts with specified criteria.'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of contacts'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :path
              key :name, :cache_id
              key :description, 'cache_id that has the saved contacts for the cached search'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :query
              key :name, :page
              key :required, false
              key :description, 'page to fetch (1 based)'
              key :type, :integer
            end

            parameter do
              key :in, :query
              key :name, :page_size
              key :required, false
              key :description, 'page size'
              key :type, :integer
            end

            parameter do
              key :in, :query
              key :name, :sort_by
              key :required, false
              key :description, 'field to sort on. valid values are last_name, first_name, id'
              key :type, :string
            end

            parameter do
              key :in, :query
              key :name, :sort_direction
              key :required, false
              key :description, 'direction to sort, either asc or desc'
              key :type, :string
            end

            parameter do
              key :in, :query
              key :name, 'fields'
              key :required, false
              key :description, 'comma separated list of field names to restrict the payload to (an optimization). valid values are: id unified_id external_id source_id name.first_name name.last_name title_info.title title_info.job_department title_info.job_level phone_numbers.work emails.work etag last_modified created_on tags company.name linkedin_url'
              key :type, :string
            end

            response 400 do
              key :description, 'Invalid request'
            end

            response 200 do
              key :description, 'will be returned  with search results'
              schema do
                key :'$ref', :'Contracts::Responses::ContactSearchResponse'
              end
            end
          end
        end

        swagger_path '/owners/{owner_id}/contacts/search/cache/{cache_id}' do
          operation :delete do
            key :tags, ['contacts']
            key :summary, 'delete cached search'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of contacts'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :path
              key :name, :cache_id
              key :description, 'cache_id that has the saved contacts for the cached search'
              key :required, true
              key :type, :string
            end

            response 400 do
              key :description, 'Invalid request'
            end

            response 204 do
              key :description, 'will be returned when cache is successfully deleted'
            end
          end
        end

        swagger_path '/owners/{owner_id}/contacts/export' do
          operation :post do
            key :tags, ['contacts']
            key :summary, 'export contacts by id '
            key :produces, ['text/csv']
            key :consumes, ['application/json']

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of contacts'
              key :required, true
              key :type, :string
            end

            parameter do
              key :type, :body
              key :name, :body
              key :in, :body
              key :description, 'POST body of search items to filter the result set.'
              key :required, true
              schema do
                key :'$ref', :'Contracts::Requests::ContactExportCreateRequest'
              end
            end


            response 400 do
              key :description, 'Invalid request'
            end

            response 200 do
              key :description, 'will be returned  with search results'
              schema do
                key :'type', :'file'
              end
            end
          end
        end


        swagger_path '/owners/{owner_id}/contacts/bulk' do
          operation :post do
            key :tags, ['contacts']
            key :summary, 'create contacts in bulk (100 per call)'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of contacts'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :query
              key :name, 'fields'
              key :required, false
              key :description, 'comma separated list of field names to restrict the payload to (an optimization). valid values are: id unified_id external_id source_id name.first_name name.last_name title_info.title title_info.job_department title_info.job_level phone_numbers.work emails.work etag last_modified created_on updated_on unified_timestamp tags company.name linkedin_url'
              key :type, :string
            end

            parameter do
              key :type, :body
              key :name, :body
              key :in, :body
              key :description, 'POST body of with contacts array to create.'
              key :required, true
              schema do
                key :'$ref', :'Contracts::Requests::BulkContactsCreateRequest'
              end
            end

            response 400 do
              key :description, 'Invalid request'
            end

            response 200 do
              key :description, 'will be returned with newly created contact_ids'
              schema do
                key :'$ref', :'Contracts::Responses::BulkContactsResponse'
              end
            end

            response 202 do
              key :description, 'will be returned when the request contacts array contains some invalid contacts that were not persisted for some reason. The invalid_requests key would have more specific error on what item in the contacts array was not persisted.'
              schema do
                key :'$ref', :'Contracts::Responses::BulkContactsResponse'
              end
            end

          end
        end

        swagger_path '/owners/{owner_id}/contacts/bulk' do
          operation :delete do
            key :tags, ['contacts']
            key :summary, 'delete contacts in bulk, based on search criteria. Default is a hard delete.'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of contacts'
              key :required, true
              key :type, :string
            end

            parameter do
              key :type, :body
              key :name, :body
              key :in, :body
              key :description, 'POST body of with search criteria. All contacts matching the criteria will be deleted.'
              key :required, true
              schema do
                key :'$ref', :'Contracts::Requests::BulkContactsDeleteRequest'
              end
            end

            response 400 do
              key :description, 'Invalid request'
            end

            response 204 do
              key :description, 'will be returned when delete is successful'
            end
          end
        end




        end




      end
    end
  end