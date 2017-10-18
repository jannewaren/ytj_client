require 'vcr'
require 'pry'
require 'awesome_print'
require 'simplecov'

SimpleCov.start do
  add_filter 'spec/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ytj_client'

RSpec.configure do |c|
  c.order = 'random'
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_replays'
  c.hook_into :webmock
  c.default_cassette_options = { match_requests_on: [:method] }
  c.configure_rspec_metadata!
end
