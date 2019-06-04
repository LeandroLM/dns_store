require 'rails_helper'

RSpec.describe Api::DnsController, type: :controller do
  describe 'POST #create' do
    let(:body) { JSON.parse(response.body) }

    context 'when the paramters are valid' do
      it 'returns success status with the created data' do
        params = { dns: { ip_address: '127.0.0.1', hostnames: ['example.com'] } }
        post :create, params: params

        expect(response).to have_http_status(:success)
        expect(body['data']['attributes']['ip_address']).to eq '127.0.0.1'
        expect(body['data']['attributes']['hostnames']).to eq ['example.com']
      end
    end

    context 'when the paramters are invalid' do
      it 'returns http success' do
        post :create, params: { dns: { ip_address: 'invalid address' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(body['errors']).to include 'Ip address is not valid'
        expect(body['errors']).to include 'must include at least 1 hostname'
      end
    end

    context 'when the parameters do not have the expected format' do
      it 'returns bad request status with an error message' do
        badly_formed_params = {
          ip_address: '127.0.0.1',
          hostnames: ['example.com']
        }
        post :create, params: badly_formed_params

        expect(response).to have_http_status(:bad_request)
        expect(body['errors']).not_to be_empty
      end
    end
  end
end
