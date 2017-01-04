require 'ytj_client/version'
require 'logger'
require 'restclient'

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/inflections'

require 'json'
require 'csv'

module YtjClient

  YTJ_API_URL = 'http://avoindata.prh.fi:80/bis/v1/'.freeze
  TR_API_URL = 'http://avoindata.prh.fi:80/tr/v1?totalResults=false&maxResults=1000&resultsFrom=0
'.freeze
  START_YEAR = 1896

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

    def fetch_all_companies(format = 'csv')
      overall_fetched_companies = 0
      end_year = Time.now.year

      end_year.downto(START_YEAR).to_a.each do |year|
        overall_fetched_companies += fetch_year(year, format)
      end

      logger.info "Fetched #{overall_fetched_companies} companies and saved in #{format}"
      return overall_fetched_companies
    rescue
      logger.error "Error fetching data from TR API: #{$!.message} - #{$!.backtrace}"
    end

    private

      def fetch_year(year, format)
        url = url = TR_API_URL+"&companyRegistrationFrom=#{year}-01-01&companyRegistrationTo=#{year}-12-31"
        fetched_companies = 0
        while true
          companies, url = fetch_1000_companies(url)
          logger.info "Fetched #{companies.size} companies."
          logger.info "Next URL: #{url}"
          save_companies(companies, format)
          fetched_companies += companies.size
          if url.blank?
            logger.info "No more companies to get for year #{year}. Last response was #{companies.size} companies: #{companies}"
            break
          end
          logger.info "Got #{fetched_companies} companies now, fetching some more"
          sleep 5
        end
        logger.info "Got #{fetched_companies} for year #{year}. Moving on."
        return fetched_companies
      rescue
        logger.error "Error fetching data for year #{year} from TR API: #{$!.message} - #{$!.backtrace}"
      end

      def fetch_1000_companies(url)
        response = JSON.parse(RestClient.get(url).body)
        return response["results"], response["nextResultsUri"]
      end

      def save_companies(companies, format)
        case format
        when 'csv'
          CSV.open("companies.csv", "ab") do |csv|
            companies.each do |company|
              csv << [company["businessId"], company["companyForm"], company["name"], company["registrationDate"]]
            end
          end
        else
          logger.info "Unknown save format"
        end
      end

      # Returns a hash with all company data from YTJ
      def api_call(business_id)
        url = "#{YTJ_API_URL}#{business_id}"
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
