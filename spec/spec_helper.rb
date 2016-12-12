$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ytj_client'
require 'vcr'
require 'pry'
require 'awesome_print'

RSpec.configure do |c|
  c.order = 'random'
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_replays'
  c.hook_into :webmock
  c.default_cassette_options = { match_requests_on: [:method] }
  c.configure_rspec_metadata!
end
