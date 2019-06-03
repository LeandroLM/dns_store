class CreateDnsService
  attr_reader :dns, :hostnames

  def initialize(ip_address, hostnames = [])
    @dns = DnsRecord.new(ip_address: ip_address)
    @hostnames = hostnames.map(&:downcase).uniq.map do |hostname|
      Hostname.find_or_initialize_by(name: hostname)
    end
  end

  def create
    return false unless valid?

    save_records!
  rescue ActiveRecord::RecordNotUnique
    retry
  rescue StandardError
    false
  end

  def errors
    @errors = dns.errors.full_messages +
              hostnames.map { |h| h.errors.full_messages }.flatten
    @errors << ['must include at least 1 hostname'] if hostnames.length.zero?
    @errors
  end

  private

  def valid?
    dns.valid? && !hostnames.empty? && hostnames.all?(&:valid?)
  end

  def save_records!
    ApplicationRecord.transaction do
      dns.save!
      hostnames.each(&:save!)
      dns.hostnames = hostnames
    end
    true
  end
end
