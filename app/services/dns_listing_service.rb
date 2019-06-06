class DnsListingService
  attr_reader :included_hostnames, :excluded_hostnames, :page

  def initialize(params)
    @included_hostnames = params['include'] || []
    @excluded_hostnames = params['exclude'] || []
    @page = params['page'] || 1
  end

  def list
    {
      data: {
        dns_records_count: matching_dns_records.length,
        dns_records: matching_dns_records,
        hostnames: hostnames_by_occurrence
      }
    }
  end

  private

  def matching_dns_records
    @matching_dns_records ||= begin
      DnsRecord
        .joins(:hostnames)
        .preload(:hostnames)
        .where(hostnames: { name: included_hostnames })
        .uniq
        .filter do |dns|
          hostnames = dns.hostnames.map(&:name)
          included_hostnames.all? { |h| h.in? hostnames } &&
            excluded_hostnames.none? { |h| h.in? hostnames }
        end
    end
  end

  def hostnames_by_occurrence
    hostnames = matching_dns_records.map(&:hostnames).flatten.map(&:name)
    hostnames -= included_hostnames
    hostnames.each_with_object(Hash.new(0)) { |name, hsh| hsh[name] += 1 }
             .map do |name, count|
               { hostname: name, matching_dns_records: count }
             end
  end
end
