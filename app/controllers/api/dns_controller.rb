module Api
  class DnsController < ApplicationController
    def create
      if dns_service.create
        render json: DnsRecordSerializer.new(dns_service.dns)
      else
        render_error(dns_service.errors)
      end
    end

    def list
      render json: {
        data: {
          dns_records_count: 2,
          dns_records: [
            DnsRecord.find_by(ip_address: '1.1.1.1'),
            DnsRecord.find_by(ip_address: '3.3.3.3')
          ],
          hostnames: [
            { hostname: 'lorem.com', matching_dns_records: 1 },
            { hostname: 'amet.com', matching_dns_records: 2 }
          ]
        }
      }
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
