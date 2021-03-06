require 'spec_helper'

describe WebUI do
  include Rack::Test::Methods

  let(:app) { WebUI }

  # Sanity check
  it 'works' do
    get '/'

    last_response.should be_ok
  end

  describe 'JSON API' do
    describe '#index' do
      it 'works' do
        get '/api/locations'

        last_response.body.should == '[]'
      end

      context 'with a location' do
        let(:location) do
          {
            name: 'for the tests',
            latitude: 42,
            longitude: 42
          }
        end

        before do
          FavoriteLocation.create(location)
        end

        it 'returns the location' do
          get '/api/locations'

          last_response.body.should include location[:name]
        end
      end
    end

    describe 'creating a new record' do
      let(:location) do
        {
          name: 'newly created',
          latitude: 1,
          longitude: 2
        }
      end

      it 'creates the model with an id' do
        post '/api/locations', location.to_json
        created = JSON.parse(last_response.body)

        created[:name].should == location[:name]
        created[:id].should_not be_nil
      end
    end

    describe 'updating a record' do
      let(:location) do
        FavoriteLocation.create(name: 'for updating')
      end

      it 'saves and returns' do
        put "/api/locations/#{location.id}", { name: 'updated' }.to_json

        new_location = JSON.parse(last_response.body)
        new_location[:name].should == 'updated'
      end
    end

    describe 'deleting a record' do
      context 'for a non-existent entry' do
        it 'throws an error' do
          delete '/api/locations/-1'

          last_response.body.should match /not found/i
        end
      end

      context 'for a record that exists' do
        let(:location) do
          FavoriteLocation.create(name: 'kill me, please')
        end

        it 'deletes the record' do
          delete "/api/locations/#{location.id}"

          FavoriteLocation.where(id: location.id).count.should == 0
        end
      end
    end
  end

  describe 'a non-existent page' do
    it 'returns a 404' do
      get '/cant/touch/this'

      last_response.status.should == 404
    end
  end
end
