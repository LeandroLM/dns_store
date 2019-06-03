require 'rails_helper'

RSpec.describe CreateDnsService, type: :service, service: true do
  let(:ip_address) { '12.24.56.78' }
  let(:invalid_ip_address) { '300.400.500.600' }
  let(:hostnames) { ['example.com', 'example2.com'] }

  context 'when the ip address is not valid' do
    let(:service) { CreateDnsService.new(:invalid_address, hostnames) }

    it 'does not create a new DNS nor new hostnames' do
      expect(service.create).to be_falsy
      expect(service.errors).not_to be_empty
      expect(DnsRecord.count).to be_zero
      expect(Hostname.count).to be_zero
    end
  end

  context 'when the ip address is valid' do
    let(:service) { CreateDnsService.new(ip_address, hostnames) }

    context 'and the address does not exist yet' do
      context "and there's no associated hostnames" do
        let(:service) { CreateDnsService.new(ip_address) }

        it 'does not create a new DNS record nor new hostnames' do
          expect(service.create).to be_falsy
          expect(service.errors).not_to be_empty
          expect(DnsRecord.count).to be_zero
          expect(Hostname.count).to be_zero
        end
      end

      context 'and some of the hostnames are invalid' do
        let(:service) { CreateDnsService.new(ip_address, ['example.com', '']) }

        it 'does not create a new DNS record nor new hostnames' do
          expect(service.create).to be_falsy
          expect(service.errors).not_to be_empty
          expect(DnsRecord.count).to be_zero
          expect(Hostname.count).to be_zero
        end
      end

      context 'and there are associated hostnames' do
        let(:service) { CreateDnsService.new(ip_address, hostnames) }

        it 'it creates a new DSN record' do
          expect(service.create).to be_truthy
          dns = DnsRecord.find_by(ip_address: ip_address)
          expect(dns).to be_present
        end

        it 'creates new hostnames and associates them with the new DNS' do
          expect(Hostname.count).to be_zero
          expect(service.create).to be_truthy
          expect(Hostname.count).to eq 2

          dns = DnsRecord.find_by(ip_address: ip_address)
          expect(dns.hostnames.map(&:name)).to eq hostnames
        end

        context 'and some of the hostnames already exist' do
          before { create(:hostname, name: 'example.com') }

          it 'it associates the new DNS with the existing hostnames' do
            expect(Hostname.count).to eq 1
            expect(service.create).to be_truthy
            expect(Hostname.count).to eq 2

            dns = DnsRecord.find_by(ip_address: ip_address)
            expect(dns.hostnames.map(&:name)).to eq hostnames
          end
        end

        context 'and some of the hostnames are duplicated' do
          let(:hostnames) { %w[example.com example2.com example.com] }

          it 'removes duplications' do
            expect(Hostname.count).to be_zero
            expect(service.create).to be_truthy
            expect(Hostname.count).to eq 2

            dns = DnsRecord.find_by(ip_address: ip_address)
            expect(dns.hostnames.map(&:name))
              .to eq ['example.com', 'example2.com']
          end
        end
      end
    end

    context 'and the address already exists' do
      before { create(:dns_record, ip_address: ip_address) }

      it 'does not create a new DNS record nor new hostnames' do
        expect(DnsRecord.count).to eq 1
        expect(Hostname.count).to be_zero

        expect(service.create).to be_falsy
        expect(service.errors).not_to be_empty

        expect(DnsRecord.count).to eq 1
        expect(Hostname.count).to be_zero
      end
    end
  end
end
