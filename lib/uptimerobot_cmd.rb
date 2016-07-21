require "uptimerobot_cmd/version"
require 'colorize'
require 'httparty'
require 'terminal-table'

module UptimerobotCmd
  APIKEY = ENV['UPTIMEROBOT_APIKEY'] || nil
  ENDPOINT_BASE_URL = 'https://api.uptimerobot.com'
  ENDPOINT_SERVICE_URLS = {
    get_monitors: '%{base_url}/getMonitors?apiKey=%{apikey}&%{json_result}',
    get_alert_contacts: '%{base_url}/getAlertContacts?apiKey=%{apikey}&%{json_result}',
  }

  class APIKEYError < StandardError; end
  
  def self.apikey_defined
    raise APIKEYError, "Please set UPTIMEROBOT_APIKEY environment variable." unless ENV['UPTIMEROBOT_APIKEY']
    true
  end
  
  def self.build_service_url(service_key, **options)
    options[:apikey] = APIKEY
    options[:base_url] = ENDPOINT_BASE_URL
    options[:json_result] = 'format=json&noJsonCallback=1'
    ENDPOINT_SERVICE_URLS[service_key] % options
  end
  
  def self.get_monitors
    if self.apikey_defined
      response = HTTParty.get(build_service_url(:get_monitors))
      response["monitors"]["monitor"]
    end
  end
  
  def self.get_alert_contacts
    if self.apikey_defined
      response = HTTParty.get(build_service_url(:get_alert_contacts))
      response["alertcontacts"]["alertcontact"]
    end
  end
  
  def self.list_alert_contacts
    if self.apikey_defined
      contacts = get_alert_contacts
      rows = []
      contacts.each do |contact|
        contact_id = contact['id']
        contact_id = contact_id.colorize(:green) if ENV['UPTIMEROBOT_COLORIZE']
        contact_info = contact['value']
        contact_info = contact_info.colorize(:light_green) if ENV['UPTIMEROBOT_COLORIZE']
        rows << [contact_id, contact_info]
      end
      Terminal::Table.new :headings => ['ID', 'Info'],
                          :rows => rows
    end
  end
end
