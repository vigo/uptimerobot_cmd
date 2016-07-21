require "uptimerobot_cmd/version"
require 'colorize'
require 'httparty'

module UptimerobotCmd
  APIKEY = ENV['UPTIMEROBOT_APIKEY'] || nil
  ENDPOINT_BASE_URL = 'https://api.uptimerobot.com'
  ENDPOINT_SERVICE_URLS = {
    get_monitors: '%{base_url}/getMonitors?apiKey=%{apikey}&format=json&noJsonCallback=1',
  }

  class APIKEYError < StandardError; end
  
  def self.apikey_defined
    raise APIKEYError, "Please set UPTIMEROBOT_APIKEY environment variable." unless ENV['UPTIMEROBOT_APIKEY']
    true
  end
  
  def self.build_service_url(service_key, **options)
    options[:apikey] = APIKEY
    options[:base_url] = ENDPOINT_BASE_URL
    ENDPOINT_SERVICE_URLS[service_key] % options
  end
  
  def self.get_monitors
    if self.apikey_defined
      response = HTTParty.get(build_service_url(:get_monitors))
      response["monitors"]["monitor"]
    end
  end
end
