module Api
  class DnsController < ApplicationController
    def create
      if dns_service.create
        render json: DnsRecordSerializer.new(dns_service.dns)
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
  end
end
