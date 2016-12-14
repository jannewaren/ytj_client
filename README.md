# ytj_client

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

