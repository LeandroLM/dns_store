class DnsRecord < ApplicationRecord
  validates :ip_address, presence: true, uniqueness: true
  validates_with ::IpAddressFormatValidator,
                 unless: proc { |record| record.ip_address.blank? }
end
