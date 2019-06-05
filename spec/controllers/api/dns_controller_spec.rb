require 'rails_helper'

RSpec.describe Api::DnsController, type: :controller do
  let(:body) { JSON.parse(response.body) }
  let(:data) { body['data'] }

  describe 'POST #create' do
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
      it 'returns unprocessable entity status with error messages' do
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

  describe 'POST #list' do
    let(:dns_record_1) { create(:dns_record, ip_address: '1.1.1.1') }
    let(:dns_record_2) { create(:dns_record, ip_address: '2.2.2.2') }
    let(:dns_record_3) { create(:dns_record, ip_address: '3.3.3.3') }
    let(:dns_record_4) { create(:dns_record, ip_address: '4.4.4.4') }
    let(:dns_record_5) { create(:dns_record, ip_address: '5.5.5.5') }
    let(:amet) { create(:hostname, name: 'amet.com') }
    let(:dolor) { create(:hostname, name: 'dolor.com') }
    let(:ipsum) { create(:hostname, name: 'ipsom.com') }
    let(:lorem) { create(:hostname, name: 'lorem.com') }
    let(:sit) { create(:hostname, name: 'sit.com') }
    let(:params) do
      {
        include: ['ipsum', 'dolor.com'],
        exclude: ['sit.com'],
        page: 1
      }
    end

    before do
      dns_record_1.hostnames = [lorem, ipsum, dolor, amet]
      dns_record_2.hostnames = [ipsum]
      dns_record_3.hostnames = [ipsum, dolor, amet]
      dns_record_4.hostnames = [ipsum, dolor, sit, amet]
      dns_record_5.hostnames = [dolor, sit]
    end

    it 'returns the total number of matching DNS records' do
      post :list, params: params

      expect(response).to have_http_status(:success)
      expect(data['dns_records_count']).to eq 2
    end

    it 'returns an array of matching DNS records that have all the hostnames ' \
       'it should include, but none of the hostnames it should exclude ' do
      post :list, params: params

      expect(response).to have_http_status(:success)

      first_record = data['dns_records'].first
      expect(first_record['id']).to eq dns_record_1.id
      expect(first_record['ip_address']).to eq dns_record_1.ip_address

      second_record = data['dns_records'].second
      expect(second_record['id']).to eq dns_record_3.id
      expect(second_record['ip_address']).to eq dns_record_3.ip_address
    end

    it 'returns an array of hostnames associated with the DNS records ' \
       'excluding any hostnames specified in the query' do
      post :list, params: params

      expect(response).to have_http_status(:success)

      hostnames = data['hostnames']
      expect(hostnames.length).to eq 2

      lorem = hostnames.find { |h| h['hostname'] == 'lorem.com' }
      expect(lorem).to be_present
      expect(lorem['matching_dns_records']).to eq 1

      amet = hostnames.find { |h| h['hostname'] == 'amet.com' }
      expect(amet).to be_present
      expect(amet['matching_dns_records']).to eq 2
    end
  end
end
