# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ytj_client/version'

Gem::Specification.new do |spec|
  spec.name          = "ytj_client"
  spec.version       = YtjClient::VERSION
  spec.authors       = ["Janne Warén"]
  spec.email         = ["janne.waren@iki.fi"]
  spec.licenses      = ['MIT']

  spec.summary       = 'Client for communicating with Finnish Patent and Registration Office (PRH) YTJ-tiedot API'
  spec.description   = 'Fetches data with business_id from the YTJ API at http://avoindata.prh.fi/ytj.html'
  spec.homepage      = 'https://github.com/jannewaren/ytj_client'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 2.3'
  spec.add_development_dependency "pry", "~> 0.10.4"
  spec.add_development_dependency 'awesome_print', '~> 1.7'

  spec.add_runtime_dependency 'rest-client', '~> 2.0'
  spec.add_runtime_dependency 'activesupport', '~> 5.1'
end
