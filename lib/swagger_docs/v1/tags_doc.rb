require 'json'
require 'swagger/blocks'

module V1
  module API
    module Documentation

      class TagsDoc
        include Swagger::Blocks

        swagger_path '/owners/{owner_id}/tags' do

          operation :get do
            key :tags, ['tags']
            key :summary, 'Simple endpoint for returning an owners tags'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of tags'
              key :required, true
              key :type, :string
            end

            response 400 do
              key :description, 'Invalid request'
            end
            response 200 do
              key :description, 'will return an array of tags along with their contact_count'
              schema do
                key :'$ref', :'Contracts::Responses::TagGetAllResponse'
              end

            end
          end
        end


        swagger_path '/owners/{owner_id}/tags' do

          operation :post do
            key :tags, ['tags']
            key :summary, 'Simple endpoint for creating a new tag'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of tag'
              key :required, true
              key :type, :string
            end

            parameter do
              key :type, :body
              key :name, :body
              key :in, :body
              key :description, 'POST body for the request. Will persist a tag on success, and return 201 with Location header where to find it'
              key :required, true
              schema do
                key :'$ref', :'Contracts::Requests::TagCreateRequest'
              end
            end

            response 400 do
              key :description, 'Invalid request'
            end
            response 201 do
              key :description, 'returned when tag is successfully created'
              header :Location do
                key :type, :string
                key :description, 'will be a URI of where to get the newly created resource'
              end

            end
          end
        end

        swagger_path '/owners/{owner_id}/tags/{tag_id}' do

          operation :put do
            key :tags, ['tags']
            key :summary, 'endpoint to update a tag name'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of tag'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :path
              key :name, :tag_id
              key :description, 'tag_id of tag'
              key :required, true
              key :type, :string
            end

            parameter do
              key :type, :body
              key :name, :body
              key :in, :body
              key :description, 'body for the request. Will update the tag name on success.'
              key :required, true
              schema do
                key :'$ref', :'Contracts::Requests::TagUpdateRequest'
              end
            end

            response 400 do
              key :description, 'Invalid request'
            end
            response 404 do
              key :description, 'tag_id not found'
            end
            response 412 do
              key :description, 'ETag supplied doesnt match the latest ETag value of the tag, update is rejected due to version conflict.'
            end
            response 204 do
              key :description, 'on successful update returns Location header to the full resource'

              header :ETag do
                key :type, :string
                key :description, 'ETag value of the tag, can be used with If-Match on update'
              end
              header :'Location' do
                key :type, :string
                key :description, 'Location header to get updated resource'
              end
            end
          end
        end

        swagger_path '/owners/{owner_id}/tags/{tag_id}' do

          operation :delete do
            key :tags, ['tags']
            key :summary, 'endpoint to delete a tag'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of tag'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :path
              key :name, :tag_id
              key :description, 'tag_id of tag'
              key :required, true
              key :type, :string
            end

            response 404 do
              key :description, 'tag_id not found'
            end

            response 204 do
              key :description, 'on successful delete'

            end
          end
        end

        swagger_path '/owners/{owner_id}/tags/{tag_id}/contacts' do

          operation :delete do
            key :tags, ['tags']
            key :summary, 'endpoint to bulk remove contacts from a tag'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of tag'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :path
              key :name, :tag_id
              key :description, 'tag_id of tag'
              key :required, true
              key :type, :string
            end

            parameter do
              key :type, :body
              key :name, :body
              key :in, :body
              key :description, 'POST body for the request. Has a list of contact_ids in the ids property to assign to this tag'
              key :required, true
              schema do
                key :'$ref', :'Contracts::Requests::TagContactsRequest'
              end
            end

            response 400 do
              key :description, 'Invalid request'
            end

            response 404 do
              key :description, 'tag_id not found'
            end

            response 204 do
              key :description, 'on successful removal of contacts from tag'
              header :'Location' do
                key :type, :string
                key :description, 'Location header of tag that was updated (would see contact_count updated)'
              end

            end
          end
        end

        swagger_path '/owners/{owner_id}/tags/{tag_id}/contacts' do

          operation :put do
            key :tags, ['tags']
            key :summary, 'endpoint to bulk assign contacts to a tag'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of tag'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :path
              key :name, :tag_id
              key :description, 'tag_id of tag'
              key :required, true
              key :type, :string
            end

            parameter do
              key :type, :body
              key :name, :body
              key :in, :body
              key :description, 'POST body for the request. Has a list of contact_ids in the ids property to assign to this tag'
              key :required, true
              schema do
                key :'$ref', :'Contracts::Requests::TagContactsRequest'
              end
            end

            response 400 do
              key :description, 'Invalid request'
            end

            response 404 do
              key :description, 'tag_id not found'
            end

            response 204 do
              key :description, 'on successful assignment of contacts to tag'
              header :'Location' do
                key :type, :string
                key :description, 'Location header of tag that was updated (would see contact_count updated)'
              end

            end
          end
        end

        swagger_path '/owners/{owner_id}/tags/{tag_id}/copy' do

          operation :post do
            key :tags, ['tags']
            key :summary, 'endpoint to copy an existing tags contacts and assign them to the new tag'

            parameter do
              key :in, :path
              key :name, :owner_id
              key :description, 'owner_id of tag'
              key :required, true
              key :type, :string
            end

            parameter do
              key :in, :path
              key :name, :tag_id
              key :description, 'tag_id of tag'
              key :required, true
              key :type, :string
            end

            parameter do
              key :type, :body
              key :name, :body
              key :in, :body
              key :description, 'body for the request. Will create a new tag with the given name, and copy assigned contacts to the new tag.'
              key :required, true
              schema do
                key :'$ref', :'Contracts::Requests::TagUpdateRequest'
              end
            end

            response 400 do
              key :description, 'Invalid request'
            end
            response 404 do
              key :description, 'tag_id not found'
            end

            response 201 do
              key :description, 'on successful update returns Location header to the full resource'
              header :'Location' do
                key :type, :string
                key :description, 'Location header to get new resource'
              end
            end
          end
        end



      end
    end
  end
end
