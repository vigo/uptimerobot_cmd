require 'uptimerobot_cmd/version'
require 'httparty'
require 'terminal-table'

module UptimerobotCmd
  APIKEY = ENV['UPTIMEROBOT_APIKEY'] || nil
  ENDPOINT_BASE_URL = 'https://api.uptimerobot.com'
  ENDPOINT_SERVICE_URLS = {
    get_monitors: '%{base_url}/getMonitors?apiKey=%{apikey}&limit=%{limit}&offset=%{offset}&%{json_result}',
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
      ['paused', :black]
    when '1'
      ['not checked yet', :black]
    when '2'
      ['up', :yellow]
    when '8'
      ['seems down', :red]
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
      limit = 50
      offset = 0
      options = {
        limit: limit,
        offset: offset,
      }
      response = HTTParty.get(::UptimerobotCmd.build_service_url(:get_monitors, options))
      total = response["total"].to_i
      output = response["monitors"]["monitor"]
      
      if total > limit
        output = []
        max_pages = total / limit
        left_over = total % limit
        max_pages += 1 if left_over > 0
        current_page = 1
        while current_page <= max_pages
          options[:offset] = offset
          response = HTTParty.get(::UptimerobotCmd.build_service_url(:get_monitors, options))
          output += response["monitors"]["monitor"]
          offset = current_page * limit
          current_page += 1
        end
      end
      
      output
    end
  end
  
  def self.search_in_monitors(input)
    if ::UptimerobotCmd.apikey_defined
      monitors = ::UptimerobotCmd.get_monitors
      monitors.select{|monitor|
        monitor['friendlyname'] =~ /#{input}/i ||
        monitor['url'] =~ /#{input}/i
      }
    end
  end
  
  def self.get_alert_contacts
    if ::UptimerobotCmd.apikey_defined
      response = HTTParty.get(::UptimerobotCmd.build_service_url(:get_alert_contacts))
      response["alertcontacts"]["alertcontact"]
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
