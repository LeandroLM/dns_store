module Api
  class DnsController < ApplicationController
    before_action :validate_params, only: :list

    def create
      if dns_service.create
        render json: DnsRecordSerializer.new(dns_service.dns)
      else
        render_error(dns_service.errors)
      end
    end

    def list
      render json: DnsListingService.new(params).list
    end

    private

    def dns_params
      params.require(:dns).permit(:ip_address, hostnames: [])
    end

    def dns_service
      @dns_service ||= CreateDnsService.new(dns_params)
    end

    def validate_params
      params.require(:page)
    end
  end
end
