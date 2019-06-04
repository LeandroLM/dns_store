class DnsRecordSerializer
  include FastJsonapi::ObjectSerializer

  set_type :dns
  attributes :ip_address
  attribute :hostnames do |object|
    object.hostnames.map(&:name)
  end
end
