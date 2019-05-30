require 'rails_helper'

RSpec.describe Hostname, type: :model do
  describe 'validations' do
    subject { Hostname.new(name: 'example.com') }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

    it 'converts :name to lowercase before saving' do
      hostname = Hostname.create!(name: 'EXAMPLE.COM')
      expect(hostname.name).to eq 'example.com'
    end
  end
end
