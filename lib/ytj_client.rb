require "ytj_client/version"
require 'logger'

module YtjClient

  class << self

    # Public method to be called
    # for now returns a set of data that I think is generally useful
    def fetch_company(business_id)
      ytj_data = api_call(business_id)
      {
        business_id:        ytj_data["businessId"],
        name:               ytj_data["name"],
        registration_date:  ytj_data["registrationDate"],
        company_form:       ytj_data["companyForm"],
        phones:             parse_phones(ytj_data),
        website:            parse_website(ytj_data),
        addresses:          parse_addresses(ytj_data)
      }
    rescue RestClient::NotFound
      logger.warn "Company #{business_id} not found"
      nil
    rescue
      logger.error "Error fetching data from YTJ: #{$!.message} - #{$!.backtrace}"
    end

    private

      # Returns a hash with all company data from YTJ
      def api_call(business_id)
        url = "http://avoindata.prh.fi:80/bis/v1/#{business_id}"
        response = RestClient.get url
        JSON.parse(response.body)["results"][0]
      end

      def parse_phones(ytj_data)
        phones = {}
        mobile_phone = ytj_data["contactDetails"].select { |contact| contact["type"] =="Mobile phone" && contact["endDate"] == nil  }.first
        phone = ytj_data["contactDetails"].select { |contact| contact["type"] =="Telephone" && contact["endDate"] == nil  }.first
        phones[:phone] = phone["value"].delete(' ') if phone
        phones[:mobile_phone] = mobile_phone["value"].delete(' ') if mobile_phone
        return phones
      end

      def parse_website(ytj_data)
        website = ytj_data["contactDetails"].select { |contact| contact["type"] =="Website address" && contact["endDate"] == nil  }.first
        website["value"] if website
      end

      def parse_addresses(ytj_data)
        addresses = {}
        visiting_address =ytj_data["addresses"].select { |address| address["type"] == 1 && address["endDate"] == nil  }.first
        postal_address = ytj_data["addresses"].select { |address| address["type"] == 2 && address["endDate"] == nil  }.first
        addresses[:visiting_address] = parse_address(visiting_address)
        addresses[:postal_address] = parse_address(postal_address)
        return addresses
      end

      def parse_address(address)
        result = []
        result << address['careOf']
        result << address['street']
        result << address['postCode']
        result << address['city']
        result << address['country']
        result.compact!
        result.join(', ')
      end

      def parse_business_lines(ytj_data)
        business_lines = []
        ytj_data["businessLines"].select{|line| line["language"] == "FI"}.each do |business_line|
          business_lines << business_line["name"]
        end
        business_lines
      end

      def logger
        @logger ||= Logger.new('log/ytj_client.log')
      end
  end
end
