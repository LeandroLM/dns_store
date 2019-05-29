class IpAddressFormatValidator < ActiveModel::Validator
  DECIMAL_IPV4_FORMAT = /^([0-9]+\.){3}[0-9]+$/.freeze

  def validate(record)
    return if valid_ipv4_address?(record.ip_address)

    record.errors.add(:ip_address, 'is not valid')
  end

  private

  def valid_ipv4_address?(address)
    address&.match?(DECIMAL_IPV4_FORMAT) &&
      address.split('.').map(&:to_i).all? { |num| num <= 255 }
  end
end
