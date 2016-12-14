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
gem 'ytj_client'
```

And then execute:

    $ bundle intall

Or install it yourself as:

    $ gem install ytj_client

## Usage

Currently only supports getting company information with a business_id:

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

