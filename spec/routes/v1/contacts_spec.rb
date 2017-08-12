require 'csv'

describe 'CB-Contacts-API v1', :type => :feature do

  describe '/owners/{owner_id}/contacts' do
    let(:owner_id){ '123-456' }
    let(:root_url) { "/v1/owners/#{owner_id}/contacts" }


    describe '/count POST' do
      let(:ext_id) { 'ext_id_123' }
      let(:external_ids) { [ext_id, ext_id + '2'] }
      let(:post_body) { ContactSearchCreateRequest::receive({:external_ids => external_ids}) }

      before(:each) do
        Contact.stub(:count_by_query_params){ 3 }

        post "#{root_url}/count", post_body.to_hash_graph.to_json,{'Content-Type' => 'application/json'}
      end

      context 'with valid request' do
        it 'is status 200' do
          expect(last_response.status).to eq 200
        end

        it 'calls Contact.count_by_query_params' do
          expect(Contact).to have_received(:count_by_query_params).exactly(1).times
        end

        it 'has .count 3 in body' do
          expect(JSON.parse(last_response.body)['count']).to eq 3
        end
      end
    end

    describe '/{contact_id} GET' do
      let(:contact_id){ 101 }
      context 'with valid id' do
        let(:tags){ nil }
        let(:request_headers) { {} }
        before(:each) do
          created_on = Time.now
          @contact = Contact.new
          @contact.id = contact_id
          @contact.first_name = 'John'
          @contact.last_name= 'Smith'
          @contact.work_email_1 = 'jsmith@acme.com'
          @contact.lock_version = 0
          @contact.updated_on = created_on
          @contact.created_on = created_on

          if tags
            mapped_tags = tags.map{|t| Tag.new { |mt|  mt.name = t; mt.owner_id = owner_id}}
            @contact.associations[:tags] = mapped_tags
          end

          Contact.stub(:fetch_by_id).with(contact_id.to_i, owner_id){ @contact }

          get "#{root_url}/#{contact_id}", {}, request_headers
        end

        subject(:contact_response){ ContactResponse.create_from_json(last_response.body.to_s) }

        it 'is status 200' do
          expect(last_response.status).to eq 200
        end

        it 'is Responses::ContactResponse' do
          expect(contact_response).to be_a(ContactResponse)
        end

        it 'is ContactResponse with contact_id 101' do
          expect(contact_response.id).to eq contact_id
        end

        it 'has .emails .type work' do
          expect(contact_response.emails.first.value).to eq 'jsmith@acme.com'
        end

        context 'with tags' do
          let(:tags) { %w(leads Business) }

          it 'has .tags in the response' do
            expect(contact_response.tags).to match_array(['leads','Business'])
          end
        end

        context 'with matching ETag' do
          let(:request_headers){ {'CONTENT_TYPE' => 'application/json','HTTP_IF_NONE_MATCH' => '"cfcd208495d565ef66e7dff9f98764da"'} }

          it 'is 304' do
            expect(last_response.status).to eq 304
          end
        end

        context 'with non matching ETag' do
          let(:request_headers){ {'CONTENT_TYPE' => 'application/json','HTTP_IF_NONE_MATCH' => '"crap_etag"'} }

          it 'is 200' do
            expect(last_response.status).to eq 200
          end
        end
      end


      context 'with id not_found' do
        before(:each) do
          Contact.stub(:fetch_by_id).with(contact_id.to_i, owner_id){ :not_found }

          get "#{root_url}/#{contact_id}"
        end

        it 'is status 404' do
          expect(last_response.status).to eq 404
        end
      end
    end

    describe '/{contact_id} DELETE' do
      let(:contact_id){ 101 }
      context 'with valid id' do
        before(:each) do
          @contact = Contact.new
          @contact.id = contact_id
          @contact.first_name = 'John'
          @contact.last_name= 'Smith'
          @contact.work_email_1 = 'jsmith@acme.com'

          Contact.stub(:fetch_by_id).with(contact_id.to_i, owner_id){ @contact }

          allow(@contact).to receive(:save).with(:changed => true)

          delete "#{root_url}/#{contact_id}"
        end
        it 'is status 204' do
          expect(last_response.status).to eq 204
        end

        it 'calls contact.save(:changed => true' do
          expect(@contact).to have_received(:save).with(:changed => true)
        end

      end

      context 'with id not_found' do
        before(:each) do
          Contact.stub(:fetch_by_id).with(contact_id.to_i, owner_id){ :not_found }

          delete "#{root_url}/#{contact_id}"
        end

        it 'is status 404' do
          expect(last_response.status).to eq 404
        end
      end
    end

    describe '/ POST' do
      let(:unified_id){ 'abcdef12312312' }
      let(:company_name){ 'ACME Corp' }
      let(:job_title){ 'Sales Lead' }
      let(:new_id) { 102030405 }
      let(:tags){ [] }
      let(:post_body) do
        ContactCreateRequest.receive(:unified_id => unified_id,
                               :source_id => 100,
                               :company_name => company_name,
                               :tags => tags,
                               :title_info => {:title => job_title}).to_hash_graph.to_json
      end

      before(:each) do
        @contact = Contact.new
        @contact.id = new_id

        Contact.stub(:create_from_request).with(anything){ @contact }
        Tag.stub(:create_uniq).with(owner_id, tags){ tags.map{|t| Tag.new{ |tag|  tag.name = t;tag.name_key = t.downcase;tag.owner_id = owner_id }} }

        allow(@contact).to receive(:save)
        allow(@contact).to receive(:add_tag)

        post "#{root_url}", post_body, {'CONTENT_TYPE' => 'application/json'}
      end

      context 'with valid request' do
        it 'calls contact.save' do
          expect(@contact).to have_received(:save)
        end

        it 'is status 201' do
          expect(last_response.status).to eq 201
        end

        it 'has Location: root_url/{contact.id}' do
          expect(last_response['Location']).to eq "#{root_url}/#{new_id}"
        end

        context 'with two new tags' do
          let(:tags){ %w(business leads)}

          it 'calls contact.add_tag twice' do
            expect(@contact).to have_received(:add_tag).exactly(2).times
          end
        end
      end

      context 'with invalid request' do
        context 'with malformed json body' do
          let(:post_body){ '{"key":"value", crap,:bad json}' }
          it 'is status 400' do
            expect(last_response.status).to eq 400
          end

          it 'includes detailed error in the body' do
            expect(last_response.body).to match(/Expected object key start/)
          end
        end

        context 'with invalid ContactCreateRequest' do
          let(:post_body) do
            ContactCreateRequest.receive(:unified_id => unified_id,
                                         :source_id => 100,
                                         :company_name => company_name,
                                         :tags => tags,
                                         :addresses => [{:street => '1234 Main', :type => 'blah'}],
                                         :title_info => {:title => job_title}).to_hash_graph.to_json
          end

          it 'is status 400' do
            expect(last_response.status).to eq 400
          end

          context 'with invalid ContactCreateRequest.tags names' do
            let(:tags){ ['good tag',' bad$tag@!,.name'] }

            it 'is status 400' do
              expect(last_response.status).to eq 400
            end
          end

          #TODO: do full invalid request response in the json body here like siq api
        end
      end
    end


    describe '/{contact_id} PUT' do
      let(:unified_id){ 'zabcdef12312312' }
      let(:company_name){ 'ACME Corp' }
      let(:job_title){ 'Sales Lead' }
      let(:new_id) { 102030405 }
      let(:tags){ [] }
      let(:version){ 'cfcd208495d565ef66e7dff9f98764da' }
      let(:request_headers){ {'CONTENT_TYPE' => 'application/json','HTTP_IF_MATCH' => '"cfcd208495d565ef66e7dff9f98764da"'} }
      let(:post_body) do
        ContactUpdateRequest.receive(:unified_id => unified_id,
                                     :source_id => 100,
                                     :company_name => company_name,

                                     :tags => tags,
                                     :title_info => {:title => job_title}).to_hash_graph.to_json
      end

      let(:updated_contact) do
        modded_time = Time.new(2017,1,1,12,30,55)
        @updated_contact = Contact.new
        @updated_contact.id = new_id
        @updated_contact.updated_on = modded_time
        @updated_contact.created_on = modded_time
        @updated_contact.lock_version = 1
        @updated_contact.job_title = job_title

        @updated_contact
      end

      before(:each) do
        @contact = Contact.new
        @contact.id = new_id
        @contact.version = version
        #@contact.version = 0

        Contact.stub(:create_from_request).with(anything){ @contact }
        Contact.stub(:find_and_modify).with(new_id,owner_id,@contact,tags) { updated_contact }

        put "#{root_url}/#{new_id}", post_body, request_headers
      end

      context 'with valid request' do
        it 'calls contact.find_and_modify' do
          expect(Contact).to have_received(:find_and_modify)
        end

        it 'calls Contact.create_from_request' do
          expect(Contact).to have_received(:create_from_request)
        end

        it 'is status 204' do
          expect(last_response.status).to eq 204
        end

        it 'has Location: root_url/{contact.id}' do
          expect(last_response['Location']).to eq "#{root_url}/#{new_id}"
        end

        it 'has ETag: header' do
          expect(last_response['ETag']).to eq '"c4ca4238a0b923820dcc509a6f75849b"' #MD5 of 1, and ETag contains ""
        end

        it 'has Last-Modified: header' do
          expect(last_response['Last-Modified']).to eq 'Sun, 01 Jan 2017 17:30:55 GMT'
        end

        #need to test 404 and 412 conditions
        context 'with different ETag in If-Match header' do
          let(:version) { 'crap_etag' }
          let(:request_headers){ {'CONTENT_TYPE' => 'application/json', 'HTTP_IF_MATCH' => '"crap_etag"'}}
          let(:updated_contact) { :version_mismatch }
          it 'is status 412' do
            expect(last_response.status).to eq 412
          end
        end

      end

      context 'with invalid request' do
        context 'with malformed json body' do
          let(:post_body){ '{"key":"value", crap,:bad json}' }
          it 'is status 400' do
            expect(last_response.status).to eq 400
          end

          it 'includes detailed error in the body' do
            expect(last_response.body).to match(/Expected object key start/)
          end
        end

        context 'with invalid ContactCreateRequest' do
          let(:post_body) do
            ContactCreateRequest.receive(:unified_id => unified_id,
                                         :source_id => 100,
                                         :company_name => company_name,
                                         :addresses => [{:street => '1234 Main', :type => 'blah'}],
                                         :title_info => {:title => job_title}).to_hash_graph.to_json
          end

          it 'is status 400' do
            expect(last_response.status).to eq 400
          end

          context 'with invalid ContactCreateRequest.tags names' do
            let(:tags){ ['good tag',' bad$tag@!,.name'] }

            it 'is status 400' do
              expect(last_response.status).to eq 400
            end
          end

          #TODO: do full invalid request response in the json body here like siq api
        end
      end
    end


    describe '/search POST' do
      context 'with external_ids filter in query_items' do
        let(:ext_id) { 'ext_id_123' }
        let(:new_id) { 555 }
        let(:external_ids) { [ext_id, ext_id + '2'] }
        let(:query_string) { '' }
        let(:post_body) { ContactSearchCreateRequest::receive({:external_ids => external_ids}) }
        before(:each) do
          created_on = Time.now
          contact = Contact.new
          contact.id = new_id
          contact.external_id = ext_id
          contact.first_name = 'John'
          contact.last_name = 'Doe'
          contact.owner_id = owner_id
          contact.created_on = created_on
          contact.updated_on =created_on

          contact2 = Contact.new
          contact2.id = new_id + 1
          contact2.external_id = ext_id + '2'
          contact2.first_name = 'Jane'
          contact2.last_name = 'Doe'
          contact2.owner_id = owner_id
          contact2.created_on = created_on
          contact2.updated_on =created_on

          @fake_contacts  = [contact,contact2]


          Contact.stub(:fetch_by_query_params){ @fake_contacts }

          #allow(@contact).to receive(:save)
          #allow(@contact).to receive(:add_tag)

          post "#{root_url}/search#{query_string}", post_body.to_hash_graph.to_json, {'CONTENT_TYPE' => 'application/json'}
        end

        context 'with invalid request' do
          context 'with invalid fields in query_string' do
            let(:query_string) { '?fields=crapfield,id' }
            subject(:error_response){ BadRequestResponse.create_from_json(last_response.body) }

            it 'is status 400' do
              expect(last_response.status).to eq 400
            end

            it 'has fields error message' do
              expect(error_response.errors.first.field).to eq 'fields'
              expect(error_response.errors.first.message).to match /valid values are/
            end
          end
        end

        context 'with valid request' do
          it 'is status 200' do
            expect(last_response.status).to eq 200
          end

          it 'calls Contact.fetch_by_query_params' do
            expect(Contact).to have_received(:fetch_by_query_params).exactly(1).times
          end

          context 'response body ' do
            subject(:search_response) do

              ContactSearchResponse.create_from_json(last_response.body.to_s)
            end
            it 'has .contacts' do
              expect(search_response.contacts.length).to eq 2
            end

            it 'has total_count' do
              expect(search_response.total_count).to eq 2
            end

            it 'has .page 1' do
              expect(search_response.page).to eq 1
            end

            it 'has .page_count 1' do
              expect(search_response.page_count).to eq 1
            end
          end
        end
      end
    end

    describe '/export POST' do
      context 'with external_ids filter in query_items' do
        let(:ext_id) { 'ext_id_123' }
        let(:new_id) { 555 }
        let(:external_ids) { [ext_id, ext_id + '2'] }
        let(:query_string) { '' }
        let(:post_body) { ContactExportCreateRequest::receive({:external_ids => external_ids}) }
        before(:each) do
          created_on = Time.now
          contact = Contact.new
          contact.id = new_id
          contact.external_id = ext_id
          contact.first_name = 'John'
          contact.last_name = 'Doe'
          contact.owner_id = owner_id
          contact.created_on = created_on
          contact.updated_on =created_on
          contact.tier = 1

          contact2 = Contact.new
          contact2.id = new_id + 1
          contact2.external_id = ext_id + '2'
          contact2.first_name = 'Jane'
          contact2.last_name = 'Doe'
          contact2.owner_id = owner_id
          contact2.created_on = created_on
          contact2.updated_on =created_on
          contact2.tier = 2

          @fake_contacts  = [contact,contact2]

          QueryCoda.stub(:create) do |p|

            qc = QueryCoda::receive({:fields => 'source_id,external_id,id,tier'.split(',')})
            db_fields = qc.fields.map{|f| QueryCoda::FIELDS_MAP[f]}
            ordered_fields = OrderedFields.new(db_fields)
            qc.set_ordered_fields(ordered_fields)

            qc

          end
          Contact.stub(:fetch_by_query_params){ @fake_contacts }

          post "#{root_url}/export#{query_string}", post_body.to_hash_graph.to_json, {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'text/csv'}
        end

        context 'with valid request' do
          it 'is status 200' do
            expect(last_response.status).to eq 200
          end

          it 'calls Contact.fetch_by_query_params' do
            expect(Contact).to have_received(:fetch_by_query_params).exactly(1).times
          end

          it 'has Access-Control-Expose-Headers header' do
            expect(last_response['Access-Control-Expose-Headers']).to eq 'Content-Disposition'
          end

          it 'has Content-Disposition' do
            expect(last_response['Content-Disposition']).to match /attachment; filename/
          end

          context 'response body ' do
            subject(:export_response) do
              CSV.parse(last_response.body.to_s, :headers => true, :encoding => 'UTF-8')
            end
            it 'has header for first row' do
              expect(export_response.first['external_id']).to eq 'ext_id_123'
            end

          end
        end
      end
    end

    describe '/bulk POST' do
      let(:unified_id){ 'zabcdef12312312' }
      let(:new_ids) { [102030405,102030406,102030407] }
      let(:request_headers){ {'CONTENT_TYPE' => 'application/json'} }
      let(:contacts){ [] }
      let(:q_string){ ''}
      let(:persisted_contacts){ nil }
      let(:batch_id){ nil }
      let(:post_body) do
         h = {:bulk_contacts => contacts}
         h[:batch_id] = batch_id if batch_id
        BulkContactsCreateRequest.receive(h).to_hash_graph.to_json
      end

      before(:each) do

        Contact.stub(:bulk_save).with(anything,owner_id) { new_ids }
        Contact.stub(:fetch_by_query_params).with(anything,owner_id,anything){ persisted_contacts } if persisted_contacts

        post "#{root_url}/bulk?#{q_string}", post_body, request_headers
      end

      context 'with invalid request' do
        subject(:error_response){ BadRequestResponse.create_from_json(last_response.body) }

        context 'with empty bulk_contacts array ' do
          it 'is status 400' do
            expect(last_response.status).to eq 400
          end

          it 'has error message in errors array' do
            expect(error_response.errors.first.field).to eq 'bulk_contacts'
            expect(error_response.errors.first.message).to match /blank/
          end
        end

        context 'with over 100 contacts array' do
          let(:contacts) do
            101.times.map do |i|
              c = Contact.new
              c.first_name = Faker::Name.first_name

              c.to_hash
            end
          end

          it 'is status 400' do
            expect(last_response.status).to eq 400
          end

          it 'has error message in errors array' do
            expect(error_response.errors.first.field).to eq 'bulk_contacts'
            expect(error_response.errors.first.message).to match /100/
          end
        end
      end

      context 'with partial valid request' do
        let(:new_ids) { [102030405] }
        let(:contacts) do
          cc = {:name => {:first_name => 'John'}, :emails => [{:type => 'work', :value => 'john@acme.com'}]}
          cc2 = {:name => {:first_name => 'Invalid'}, :phone_numbers => [{:type => 'work', :value => 'really long invalid phone number that we will not persist due to an overflow............................................'}]}

          [cc,cc2]
        end

        it 'is status 202' do
          expect(last_response.status).to eq 202
        end

        it 'calls Contact.bulk_save' do
          expect(Contact).to have_received(:bulk_save)
        end

        context 'has response body BulkContactsResponse' do
          subject(:bulk_response) { BulkContactsResponse::create_from_json(last_response.body.to_s) }

          it 'has .new_contact_ids' do
            expect(bulk_response.contacts.map(&:id)).to contain_exactly(*new_ids)
          end

          it 'has .invalid_requests' do
            expect(bulk_response.invalid_requests.first.request_id).to eq '2'
            expect(bulk_response.invalid_requests.first.errors.first.field).to eq 'work_phone_1' #might want to change this
          end
        end

        context 'with request failing validation (too many emails)' do
          let(:contacts) do
            cc = {:name => {:first_name => 'John'}, :emails => [{:type => 'work', :value => 'john@acme.com'}]}
            cc2 = {:name => {:first_name => 'Invalid'}, :emails => [{:type => 'work', :value => 'j1@email.com'},{:type => 'work', :value => 'j2@email.com'},{:type => 'work', :value => 'j3@email.com'}, {:type => 'work', :value => 'j4@email.com'}]}

            [cc,cc2]
          end

          context 'has response body BulkContactsResponse' do
            subject(:bulk_response) { BulkContactsResponse::create_from_json(last_response.body.to_s) }

            it 'has .contacts.id' do
              expect(bulk_response.contacts.map(&:id)).to contain_exactly(*new_ids)
            end

            it 'has .invalid_requests' do
              expect(bulk_response.invalid_requests.first.request_id).to eq '2'
              expect(bulk_response.invalid_requests.first.errors.first.field).to eq 'emails' #might want to change this
              expect(bulk_response.invalid_requests.first.errors.first.message).to match /emails cant have more than 3 of type work/
            end
          end
        end


      end

      context 'with valid request' do
        let(:new_ids) { [102030405,102030406] }
        let(:contacts) do
          cc = {:name => {:first_name => 'John'}, :emails => [{:type => 'work', :value => 'john@acme.com'}], :id => new_ids.first, :updated_on => Time.now, :unified_timestamp => 98765}
          cc2 = {:name => {:first_name => 'Jane'}, :phone_numbers => [{:type => 'work', :value => '202-999-0909'}], :id => new_ids[-1], :updated_on => Time.now, :unified_timestamp => 123456}

          [cc,cc2]
        end

        it 'is status 200' do
          expect(last_response.status).to eq 200
        end

        it 'calls Contact.bulk_save' do
          expect(Contact).to have_received(:bulk_save).exactly(1).times
        end

        context 'has response body BulkContactsResponse' do
          subject(:bulk_response) { BulkContactsResponse::create_from_json(last_response.body.to_s) }

          it 'has .new_contact_ids' do
            expect(bulk_response.contacts.map(&:id)).to contain_exactly(*new_ids)
          end

          it 'has no .invalid_requests' do
            expect(JSON.parse(last_response.body.to_s)['invalid_requests']).to be nil
          end
        end

        context 'with fields querystring passed' do
          let(:persisted_contacts) do
            cc = {:name => {:first_name => 'John'}, :emails => [{:type => 'work', :value => 'john@acme.com'}], :id => new_ids.first, :updated_on => Time.now, :created_on => Time.now, :unified_timestamp => 98765}
            cc2 = {:name => {:first_name => 'Jane'}, :phone_numbers => [{:type => 'work', :value => '202-999-0909'}], :id => new_ids[-1], :updated_on => Time.now, :created_on => Time.now, :unified_timestamp => 123456}
           now = Time.now
           p_c = Contact.create_from_request(ContactCreateRequest.receive(cc))
            p_c.created_on = now
            p_c.updated_on = now
           p_cc = Contact.create_from_request(ContactCreateRequest.receive(cc2))
            p_cc.created_on = now
            p_cc.updated_on = now
            [p_c,p_cc]
          end
          let(:q_string){ 'fields=unified_id,updated_on,id'}

          it 'is status 200' do
            expect(last_response.status).to eq 200
          end

          it 'calls Contact.bulk_save' do
            expect(Contact).to have_received(:bulk_save).exactly(1).times
          end

          it 'calls Contact.fetch_by_query_params' do
            expect(Contact).to have_received(:fetch_by_query_params).exactly(1).times
          end

          context 'has response body BulkContactsResponse' do
            subject(:bulk_response) { BulkContactsResponse::create_from_json(last_response.body.to_s) }



            it 'has no .invalid_requests' do
              expect(JSON.parse(last_response.body.to_s)['invalid_requests']).to be nil
            end
          end
        end

        context 'with batch_id post body set' do
          let(:persisted_contacts) do
            cc = {:name => {:first_name => 'John'}, :emails => [{:type => 'work', :value => 'john@acme.com'}], :id => new_ids.first, :updated_on => Time.now, :created_on => Time.now, :unified_timestamp => 98765}
            cc2 = {:name => {:first_name => 'Jane'}, :phone_numbers => [{:type => 'work', :value => '202-999-0909'}], :id => new_ids[-1], :updated_on => Time.now, :created_on => Time.now, :unified_timestamp => 123456}
            now = Time.now
            p_c = Contact.create_from_request(ContactCreateRequest.receive(cc))
            p_c.created_on = now
            p_c.updated_on = now
            p_cc = Contact.create_from_request(ContactCreateRequest.receive(cc2))
            p_cc.created_on = now
            p_cc.updated_on = now
            [p_c,p_cc]
          end
          let(:batch_id){ 'batch-222' }

          it 'is status 200' do
            expect(last_response.status).to eq 200
          end

          it 'calls Contact.bulk_save' do
            expect(Contact).to have_received(:bulk_save).exactly(1).times
          end

          it 'does not call Contact.fetch_by_query_params' do
            expect(Contact).to have_received(:fetch_by_query_params).exactly(0).times
          end

          context 'has response body BulkContactsResponse' do
            subject(:bulk_response) { BulkContactsResponse::create_from_json(last_response.body.to_s) }

            it 'has .batch_id property' do
              expect(JSON.parse(last_response.body.to_s)['batch_id']).to eq 'batch-222'
            end

            it 'has no .invalid_requests' do
              expect(JSON.parse(last_response.body.to_s)['invalid_requests']).to be nil
            end
          end
        end


      end


    end

    describe '/bulk DELETE' do
      let(:request_headers){ {'CONTENT_TYPE' => 'application/json'} }
      let(:ids){ [12345,67890] }
      let(:post_body){ BulkContactsDeleteRequest.receive(:ids => ids).to_hash_graph.to_json }

      before(:each) do
        Contact.stub(:delete_by_query_params).with(anything,owner_id) { 2 }
        delete "#{root_url}/bulk", post_body, request_headers
      end

      context 'with valid request' do
        it 'is status 204' do
          expect(last_response.status).to eq 204
        end

        it 'calls Contact.delete_by_query_params' do
          expect(Contact).to have_received(:delete_by_query_params).exactly(1).times
        end
      end
    end


    describe '/search/cache POST' do
      context 'with external_ids filter in query_items' do
        let(:ext_id) { 'ext_id_123' }
        let(:new_id) { 555 }
        let(:cache_id){ 100000 }
        let(:external_ids) { [ext_id, ext_id + '2'] }
        let(:query_string) { '' }
        let(:post_body) { ContactSearchCreateRequest::receive({:external_ids => external_ids}) }
        before(:each) do
          created_on = Time.now
          contact = Contact.new
          contact.id = new_id
          contact.external_id = ext_id
          contact.first_name = 'John'
          contact.last_name = 'Doe'
          contact.owner_id = owner_id
          contact.created_on = created_on
          contact.updated_on =created_on

          contact2 = Contact.new
          contact2.id = new_id + 1
          contact2.external_id = ext_id + '2'
          contact2.first_name = 'Jane'
          contact2.last_name = 'Doe'
          contact2.owner_id = owner_id
          contact2.created_on = created_on
          contact2.updated_on =created_on

          @fake_contacts  = [contact,contact2]

          Contact.stub(:fetch_by_query_params){ @fake_contacts }

          @contact_search = ContactSearch.create_from_request(post_body)
          @contact_search.id = cache_id

          allow(@contact_search).to receive(:save)

          ContactSearch.stub(:create_from_request) { @contact_search }
          CachedContact.stub(:bulk_save_cache){ 1 }
          CachedContact.stub(:count_by_search_id){ @fake_contacts.count }

          post "#{root_url}/search/cache#{query_string}", post_body.to_hash_graph.to_json, {'CONTENT_TYPE' => 'application/json'}
        end

        context 'with invalid request' do
          context 'with invalid fields in query_string' do
            let(:query_string) { '?fields=crapfield,id' }
            subject(:error_response){ BadRequestResponse.create_from_json(last_response.body) }

            it 'is status 400' do
              expect(last_response.status).to eq 400
            end

            it 'has fields error message' do
              expect(error_response.errors.first.field).to eq 'fields'
              expect(error_response.errors.first.message).to match /valid values are/
            end
          end
        end

        context 'with valid request' do
          it 'is status 201' do
            expect(last_response.status).to eq 201
          end

          it 'has Location header' do
            expect(last_response['Location']).to eq "#{root_url}/search/cache/#{cache_id}"
          end

          it 'calls Contact.fetch_by_query_params' do
            expect(Contact).to have_received(:fetch_by_query_params).exactly(1).times
          end

          it 'calls ContactSearch.save' do
            expect(@contact_search).to have_received(:save).exactly(1).times
          end

          it 'calls CachedContact.bulk_save_cache' do
            expect(CachedContact).to have_received(:bulk_save_cache).exactly(1).times
          end

          it 'calls CachedContact.count_by_search_id' do
            expect(CachedContact).to have_received(:count_by_search_id).exactly(1).times
          end

          it 'has X-Total-Count header' do
            expect(last_response['X-Total-Count']).to eq '2'
          end
        end
      end
    end


    describe '/search/cache/{cache_id} GET' do
      let(:cache_id){ 123455554321 }
      let(:ext_id) { 'ext_id_123' }
      let(:new_id) { 555 }
      let(:fake_contacts)do
        created_on = Time.now
        contact = CachedContact.new
        contact.id = new_id
        contact.external_id = ext_id
        contact.first_name = 'John'
        contact.last_name = 'Doe'
        contact.owner_id = owner_id
        contact.created_on = created_on
        contact.updated_on =created_on

        contact2 = CachedContact.new
        contact2.id = new_id + 1
        contact2.external_id = ext_id + '2'
        contact2.first_name = 'Jane'
        contact2.last_name = 'Doe'
        contact2.owner_id = owner_id
        contact2.created_on = created_on
        contact2.updated_on =created_on

        @fake_contacts  = [contact,contact2]
      end
      before(:each) do

        CachedContact.stub(:fetch_by_search_id){ fake_contacts }

        get "#{root_url}/search/cache/#{cache_id}"
      end

      context 'with valid cache_id' do

        it 'is status 200' do
          expect(last_response.status).to eq 200
        end

        context 'with valid request' do
          it 'is status 200' do
            expect(last_response.status).to eq 200
          end

          it 'calls Contact.fetch_by_search_id' do
            expect(CachedContact).to have_received(:fetch_by_search_id).with(cache_id.to_s,owner_id,anything).exactly(1).times
          end

          context 'response body ' do
            subject(:search_response) do

              ContactSearchResponse.create_from_json(last_response.body.to_s)
            end
            it 'has .contacts' do
              expect(search_response.contacts.length).to eq 2
            end

            it 'has total_count' do
              expect(search_response.total_count).to eq 2
            end

            it 'has .page 1' do
              expect(search_response.page).to eq 1
            end

            it 'has .page_count 1' do
              expect(search_response.page_count).to eq 1
            end
          end
        end

        context 'with invalid cache_id' do
          subject(:error_response){ BadRequestResponse.create_from_json(last_response.body) }

          context 'with not a number in cache_id param' do
            let(:cache_id){ 'crap_cache'}

            it 'is status 400' do
              expect(last_response.status).to eq 400
            end

            it 'has fields error message' do
              expect(error_response.errors.first.field).to eq 'cache_id'
              expect(error_response.errors.first.message).to match /is not a number/
            end
          end

          context 'with cache_id overflow' do
            let(:cache_id){ '92233720368547758100'}

            it 'is status 400' do
              expect(last_response.status).to eq 400
            end

            it 'has fields error message' do
              expect(error_response.errors.first.field).to eq 'cache_id'
              expect(error_response.errors.first.message).to match /must be less than or equal to 9223372036854775807/
            end
          end
        end

        context 'with cache not_found' do
          let(:fake_contacts){ [] }

          it 'is status 404' do
            expect(last_response.status).to eq 404
          end

          it 'calls Contact.fetch_by_search_id' do
            expect(CachedContact).to have_received(:fetch_by_search_id).with(cache_id.to_s,owner_id,anything).exactly(1).times
          end


        end


      end

    end

    describe '/search/cache/{cache_id} DELETE' do
      let(:cache_id){ 123455554321 }
      let(:ext_id) { 'ext_id_123' }
      let(:new_id) { 555 }

      context 'with valid cache_id' do
        before(:each) do

          @contact_search = ContactSearch.new
          @contact_search.id = cache_id
          @contact_search.owner_id = owner_id

          CachedContact.stub(:delete_by_search_id){ 2 }
          ContactSearch.stub(:fetch_by_id){ @contact_search }

          allow(@contact_search).to receive(:delete)

          delete "#{root_url}/search/cache/#{cache_id}"
        end

        it 'is status 204' do
          expect(last_response.status).to eq 204
        end

        it 'calls CachedContact::delete_by_search_id' do
          expect(CachedContact).to have_received(:delete_by_search_id).exactly(1).times
        end

        it 'calls ContactSearch::fetch_by_id' do
          expect(ContactSearch).to have_received(:fetch_by_id).exactly(1).times
        end

        it 'deletes ContactSearch' do
          expect(@contact_search).to have_received(:delete)
        end
      end

    end


  end

end
