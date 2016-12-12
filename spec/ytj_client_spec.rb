require 'spec_helper'
require 'rest-client'


describe YtjClient do
  it 'has a version number' do
    expect(YtjClient::VERSION).not_to be nil
  end

  it 'fetches a company with business_id', vcr: { cassette_name: 'ytj_fetch_success' } do
    data = described_class.fetch_company('2331972-7')
    expect(data[:name]).to eq('Verso Food Oy')
    ap data
  end

  it 'handles failures nicely', vcr: { cassette_name: 'ytj_fetch_error_notfound' } do
    expect(described_class.fetch_company('2501710-8')).to be nil
  end

end
