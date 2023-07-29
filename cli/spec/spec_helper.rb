require 'vcr'
require 'webmock/rspec'
require_relative '../all'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = false
  config.configure_rspec_metadata!

  config.default_cassette_options = {
    match_requests_on: %i[method uri body],
  }
end


RSpec.configure do |config|
  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join('_').gsub(/[^\w\/]+/, '_')
    options = example.metadata.slice(:record, :match_requests_on)#.except(:example_group)
    WebMock.enable!
    VCR.eject_cassette(name)
    VCR.use_cassette(name, options) { example.call }
    WebMock.disable!
  end
end
