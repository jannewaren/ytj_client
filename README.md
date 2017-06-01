# ytj_client

[![Gem Version](https://badge.fury.io/rb/ytj_client.svg)](https://badge.fury.io/rb/ytj_client)
[![Dependency Status](https://gemnasium.com/badges/github.com/jannewaren/ytj_client.svg)](https://gemnasium.com/github.com/jannewaren/ytj_client)
[![Build Status](https://travis-ci.org/jannewaren/ytj_client.svg?branch=master)](https://travis-ci.org/jannewaren/ytj_client)

[![Test Coverage](https://codeclimate.com/github/jannewaren/ytj_client/badges/coverage.svg)](https://codeclimate.com/github/jannewaren/ytj_client/coverage)
[![Code Climate](https://codeclimate.com/github/jannewaren/ytj_client/badges/gpa.svg)](https://codeclimate.com/github/jannewaren/ytj_client)
[![Issue Count](https://codeclimate.com/github/jannewaren/ytj_client/badges/issue_count.svg)](https://codeclimate.com/github/jannewaren/ytj_client)


A really small gem to fetch and parse data from the Finnish Patent and Registration Office's (PRH) YTJ-tiedot (business information system) API at http://avoindata.prh.fi/ytj.html

Makes the API call for you and parses the relevant (in my opinion) information to a convenient format (Ruby hash).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ytj_client', '~> 0.3'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ytj_client

## Usage

### fetch_company

Fetch company details with a business_id:

```ruby
require 'ytj_client'
YtjClient.fetch_company('2331972-7')
# => #Hash {
#           :business_id => "2331972-7",
#                  :name => "Verso Food Oy",
#     :registration_date => "2010-04-20",
#          :company_form => "OY",
#                :phones => {
#         :mobile_phone => "+358400770697"
#     },
#               :website => "www.versofood.fi",
#             :addresses => {
#         :visiting_address => "Loisteputki 4, 00750, HELSINKI",
#           :postal_address => "Loisteputki 4, 00750, HELSINKI"
#     }
# }
```

### fetch_companies

Fetch companies between two dates.

```ruby
require 'ytj_client'
companies = YtjClient.fetch_companies(start_date: '2017-05-01',
                                      end_date: '2017-05-31',
                                      options: { mode: :array })
companies.each { |company| p company.inspect }
```

### fetch_all_companies

Fetch all companies that are available in the TR API since the year 1896. This is well over 300 000 companies so it will take a while. Saves the results in a companies.csv file.

```ruby
require 'ytj_client'
YtjClient.fetch_all_companies
```

## Version history

### 0.3.2 (2017-06-01)

- Changed the field order in CSV file

### 0.3.1 (2017-05-31)

- Minor changes, refactoring
- Better documentation

### 0.3.0 (2017-05-31)

- Breaking changes, new API methods:
  - fetch_company (fetch details of a company with business_id)
  - fetch_companies (fetch companies between two dates)
  - fetch_all_companies (fetch all companies since the year 1896)
- fetch_companies supports :mode argument, to save into :csv or just return the :array
- Dependency updates

### 0.2.3

- Fixes to fetching all the companies:
  - fetch one year and 1000 companies at a time
  - save to csv right away

### 0.2.2

- fetch all Finnish companies from TR api

### 0.2.1

- first working Version
- fetching company details with business_id
