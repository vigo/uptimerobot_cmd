require 'uptimerobot_cmd/version'
require 'colorize'
require 'httparty'
require 'terminal-table'

module UptimerobotCmd
  APIKEY = ENV['UPTIMEROBOT_APIKEY'] || nil
  ENDPOINT_BASE_URL = 'https://api.uptimerobot.com'
  ENDPOINT_SERVICE_URLS = {
    get_monitors: '%{base_url}/getMonitors?apiKey=%{apikey}&%{json_result}',
    get_alert_contacts: '%{base_url}/getAlertContacts?apiKey=%{apikey}&%{json_result}',
    add_new_monitor: '%{base_url}/newMonitor?apiKey=%{apikey}&%{json_result}'\
                     '&monitorType=%{monitor_type}'\
                     '&monitorFriendlyName=%{friendly_name}'\
                     '&monitorURL=%{monitor_url}'\
                     '&monitorAlertContacts=%{contact_id}',
    delete_monitor: '%{base_url}/deleteMonitor?apiKey=%{apikey}&%{json_result}'\
                    '&monitorID=%{monitor_id}',
  }
  
  class APIKEYError < StandardError; end
  class OptionsError < StandardError; end
  
  def self.human_readable_status(status_code)
    case status_code
    when '0'
      ['paused', :light_black]
    when '1'
      ['not checked yet', :black]
    when '2'
      ['up', :yellow]
    when '8'
      ['seems down', :light_red]
    when '9'
      ['down', :red]
    end
  end
  def self.apikey_defined
    raise ::UptimerobotCmd::APIKEYError, "Please set UPTIMEROBOT_APIKEY environment variable." unless ENV['UPTIMEROBOT_APIKEY']
    true
  end
  
  def self.build_service_url(service_key, **options)
    options[:apikey] = ::UptimerobotCmd::APIKEY
    options[:base_url] = ::UptimerobotCmd::ENDPOINT_BASE_URL
    options[:json_result] = 'format=json&noJsonCallback=1'
    ::UptimerobotCmd::ENDPOINT_SERVICE_URLS[service_key] % options
  end
  
  def self.get_monitors
    if ::UptimerobotCmd.apikey_defined
      response = HTTParty.get(::UptimerobotCmd.build_service_url(:get_monitors))
      response["monitors"]["monitor"]
    end
  end
  
  def self.search_in_monitors(input)
    monitors = ::UptimerobotCmd.get_monitors
    monitors.select{|monitor|
      monitor['friendlyname'] =~ /#{input}/i ||
      monitor['url'] =~ /#{input}/i
    }
  end
  
  def self.get_search_results(input)
    results = ::UptimerobotCmd.search_in_monitors(input)
    rows = []
    table_title = 'Found %d monitor(s)' % results.count
    table_title = table_title.colorize(:yellow) if ENV['UPTIMEROBOT_COLORIZE']
    results.each do |monitor|
      monitor_id = monitor['id']
      monitor_id = monitor_id.colorize(:green) if ENV['UPTIMEROBOT_COLORIZE']
      status_data = ::UptimerobotCmd.human_readable_status(monitor['status'])
      status = status_data[0]
      status = status_data[0].colorize(status_data[1]) if ENV['UPTIMEROBOT_COLORIZE']
      friendly_name = monitor['friendlyname']
      friendly_name = friendly_name.colorize(:light_white) if ENV['UPTIMEROBOT_COLORIZE']
      url = monitor['url']
      url = url.colorize(:default) if ENV['UPTIMEROBOT_COLORIZE']
      rows << [monitor_id, status, friendly_name, url]
    end
    Terminal::Table.new :headings => ['ID', 'Status', 'Name', 'Url'],
                        :rows => rows,
                        :title => table_title
  end
    
  def self.get_alert_contacts
    if ::UptimerobotCmd.apikey_defined
      response = HTTParty.get(::UptimerobotCmd.build_service_url(:get_alert_contacts))
      response["alertcontacts"]["alertcontact"]
    end
  end
  
  def self.list_alert_contacts
    if ::UptimerobotCmd.apikey_defined
      contacts = ::UptimerobotCmd.get_alert_contacts
      rows = []
      table_title = 'Listing %d contact(s)' % contacts.count
      table_title = table_title.colorize(:yellow) if ENV['UPTIMEROBOT_COLORIZE']
      contacts.each do |contact|
        contact_id = contact['id']
        contact_id = contact_id.colorize(:green) if ENV['UPTIMEROBOT_COLORIZE']
        contact_info = contact['value']
        contact_info = contact_info.colorize(:light_green) if ENV['UPTIMEROBOT_COLORIZE']
        rows << [contact_id, contact_info]
      end
      Terminal::Table.new :headings => ['ID', 'Info'],
                          :rows => rows,
                          :title => table_title
    end
  end
  
  def self.get_list_monitors
    if ::UptimerobotCmd.apikey_defined
      monitors = ::UptimerobotCmd.get_monitors
      table_title = 'Monitoring %d site(s)' % monitors.count
      table_title = table_title.colorize(:yellow) if ENV['UPTIMEROBOT_COLORIZE']
      rows = []
      monitors.each do |monitor|
        monitor_id = monitor['id']
        monitor_id = monitor_id.colorize(:green) if ENV['UPTIMEROBOT_COLORIZE']
        status_data = ::UptimerobotCmd.human_readable_status(monitor['status'])
        status = status_data[0]
        status = status_data[0].colorize(status_data[1]) if ENV['UPTIMEROBOT_COLORIZE']
        friendly_name = monitor['friendlyname']
        friendly_name = friendly_name.colorize(:light_white) if ENV['UPTIMEROBOT_COLORIZE']
        url = monitor['url']
        url = url.colorize(:default) if ENV['UPTIMEROBOT_COLORIZE']
        rows << [monitor_id, status, friendly_name, url]
      end
      Terminal::Table.new :headings => ['ID', 'Status', 'Name', 'Url'],
                          :rows => rows,
                          :title => table_title
    end
  end
  
  def self.add_new_monitor(**options)
    if ::UptimerobotCmd.apikey_defined
      raise ::UptimerobotCmd::OptionsError, "Please provide url to monitor" unless options[:monitor_url]
      options[:contact_id] ||= ENV['UPTIMEROBOT_DEFAULT_CONTACT']
      options[:monitor_type] ||= 1
      options[:friendly_name] ||= options[:monitor_url]
      raise ::UptimerobotCmd::OptionsError, "Please provide Contact ID" unless options[:contact_id]
      response = HTTParty.get(::UptimerobotCmd.build_service_url(:add_new_monitor, options))
      [response.code, response['stat']]
    end
  end
  
  def self.delete_monitor(**options)
    if ::UptimerobotCmd.apikey_defined
      raise ::UptimerobotCmd::OptionsError, "Please provide site ID" unless options[:monitor_id]
      response = HTTParty.get(::UptimerobotCmd.build_service_url(:delete_monitor, options))
      [response.code, response['stat']]
    end
  end
end
