module Api
  class DnsController < ApplicationController
    def create
      if dns_service.create
        render_success(dns: serialized_dns)
      else
        render_error(dns_service.errors)
      end
    end

    private

    def dns_params
      params.require(:dns).permit(:ip_address, hostnames: [])
    end

    def dns_service
      @dns_service ||= CreateDnsService.new(dns_params)
    end

    def serialized_dns
      {
        ip_address: dns_service.dns.ip_address,
        hostnames: dns_service.dns.hostnames.map(&:name)
      }
    end
  end
end
