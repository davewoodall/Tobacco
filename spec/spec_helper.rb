require 'tobacco'
require 'pry'
require 'vcr'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/support/vcr_cassettes'
    c.hook_into :fakeweb
    c.allow_http_connections_when_no_cassette = true
  end

  config.extend VCR::RSpec::Macros
end
