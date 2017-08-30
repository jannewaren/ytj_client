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
require 'date'

module YtjClient

  YTJ_API_URL = 'http://avoindata.prh.fi:80/bis/v1/'.freeze
  TR_API_URL = 'http://avoindata.prh.fi:80/tr/v1?totalResults=false&maxResults=1000&resultsFrom=0
'.freeze
    START_YEAR = 1896
  CSV_FILENAME = 'companies.csv'.freeze

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

    def fetch_all_companies
      overall_fetched_companies = []

      end_year = Time.now.year
      end_year.downto(START_YEAR).to_a.each do |year|
        overall_fetched_companies << fetch_timespan(start_date: "#{year}-01-01", end_date: "#{year}-12-31", options: {mode: :csv})
      end

      logger.info "Fetched #{overall_fetched_companies.size} companies and saved to #{CSV_FILENAME}"
      overall_fetched_companies.flatten
    rescue
      logger.error "Error fetching data from TR API: #{$!.message} - #{$!.backtrace}"
    end

    def fetch_companies(start_date:, end_date:, options: {})
      overall_fetched_companies = fetch_timespan(start_date: start_date, end_date: end_date, options: options)
      logger.info "Fetched #{overall_fetched_companies.size} companies."
      overall_fetched_companies.flatten
    rescue
      logger.error "Error fetching data from TR API: #{$!.message} - #{$!.backtrace}"
    end

    private

      def fetch_timespan(start_date:, end_date:, options: {})
        url = url = TR_API_URL+"&companyRegistrationFrom=#{start_date}&companyRegistrationTo=#{end_date}"
        fetched_companies = 0
        all_companies = []
        while true
          companies, url = fetch_1000_companies(url)
          logger.info "Fetched #{companies.size} companies."
          logger.info "Next URL: #{url}"
          case options[:mode]
          when :csv
            logger.debug "Saving to CSV file."
            save_companies(companies)
            all_companies << companies
          when :array
            logger.debug "Returning as an Array."
            all_companies << companies
          end
          fetched_companies += companies.size
          if url.blank?
            logger.info "No more companies to get for between #{start_date} and #{end_date}. Last response was #{companies.size} companies: #{companies}"
            break
          end
          logger.info "Got #{fetched_companies} companies now, fetching some more"
          sleep 5
        end
        logger.info "Got #{fetched_companies} companies between #{start_date} and #{end_date}. Moving on."
        all_companies.flatten
      end

      def fetch_1000_companies(url)
        response = JSON.parse(RestClient.get(url).body)
        return response["results"], response["nextResultsUri"]
      end

      def save_companies(companies)
        CSV.open(CSV_FILENAME, "ab") do |csv|
          companies.each do |company|
            csv << [company["businessId"], company["companyForm"], company["name"], company["registrationDate"]]
          end
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
        visiting_address = ytj_data["addresses"].select { |address| address["type"] == 1 && address["endDate"] == nil  }.first
        postal_address = ytj_data["addresses"].select { |address| address["type"] == 2 && address["endDate"] == nil  }.first
        addresses[:visiting_address] = parse_address(visiting_address)
        addresses[:postal_address] = parse_address(postal_address)
        return addresses
      end

      def parse_address(address)
        return '' unless address

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
