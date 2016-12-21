require 'spec_helper'
require 'rest-client'

describe YtjClient do
  it 'has a version number' do
    expect(YtjClient::VERSION).not_to be nil
  end

  context 'fetching a single company from YTJ API' do
    it 'fetches a company with business_id', vcr: { cassette_name: 'ytj_fetch_success' } do
      data = described_class.fetch_company('2331972-7')
      expect(data[:business_id]).to eq('2331972-7')
      expect(data[:registration_date]).to eq('2010-04-20')
      expect(data[:company_form]).to eq('OY')
      expect(data[:phones][:mobile_phone]).to eq('+358400770697')
      expect(data[:website]).to eq('www.versofood.fi')
      expect(data[:addresses][:visiting_address]).to eq('Loisteputki 4, 00750, HELSINKI')
      expect(data[:addresses][:postal_address]).to eq('Loisteputki 4, 00750, HELSINKI')
      ap data
    end

    it 'handles failures nicely', vcr: { cassette_name: 'ytj_fetch_error_notfound' } do
      expect(described_class.fetch_company('2501710-8')).to be nil
    end
  end

  context 'fetches all companies from TR API since past few months' do
    it 'fetches all companies', vcr: { cassette_name: 'tr_fetch_all_success', allow_playback_repeats: true } do
      data = described_class.fetch_all_companies('2016-10-01')
      expect(data.size).to eq 3467
    end
  end



end
