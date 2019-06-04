require 'rails_helper'

RSpec.describe DnsRecord, type: :model do
  describe 'validations' do
    subject { DnsRecord.new(ip_address: '255.0.0.1') }
    it { is_expected.to validate_presence_of(:ip_address) }
    it { is_expected.to validate_uniqueness_of(:ip_address).case_insensitive }
    it { is_expected.to have_and_belong_to_many(:hostnames) }

    let(:valid_address) { '128.54.34.14' }
    let(:invalid_addresses) do
      %w[localhost 128.54.34.14. 128.54.34.14.87 278.54.34.14 138.foo.bar.9]
    end

    it 'validates that :ip_address has a valid IPv4 format' do
      invalid_addresses.each do |address|
        subject.ip_address = address
        expect(subject).not_to be_valid
        expect(subject.errors[:ip_address]).to include 'is not valid'
      end

      subject.ip_address = valid_address
      expect(subject).to be_valid
      expect(subject.errors[:ip_address]).to be_blank
    end
  end
end
