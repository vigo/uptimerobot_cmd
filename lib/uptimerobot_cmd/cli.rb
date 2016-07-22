require 'thor'
require 'uptimerobot_cmd'

module UptimerobotCmd
  class CLI < Thor

    option :color, :type => :boolean
    desc "list_monitors", "List current monitors"
    long_desc <<-LONGDESC
        `uptimerobot_cmd list_monitors` will print out all available monitors
        with ID/Status/Name/URL format. Use `--color` option for colorized
        output.
        
        \x5
        \x5> uptimerobot_cmd list_monitors
        \x5> uptimerobot_cmd list_monitors --color
    LONGDESC
    def list_monitors
      ENV['UPTIMEROBOT_COLORIZE'] = '1' if options[:color]
      puts UptimerobotCmd.get_list_monitors
    end

    option :color, :type => :boolean
    desc "list_contacts", "List current contacts for monitors"
    long_desc <<-LONGDESC
      `uptimerobot_cmd list_contacts` will print out all available contacts
      for monitors. Use `--color` option for colorized
        \x5
        \x5> uptimerobot_cmd list_contacts
        \x5> uptimerobot_cmd list_contacts --color
    LONGDESC
    def list_contacts
      ENV['UPTIMEROBOT_COLORIZE'] = '1' if options[:color]
      puts UptimerobotCmd.list_alert_contacts
    end
    
    option :url, :required => true
    option :contact_id
    option :name
    desc "add_new_monitor", "Add new service for monitor"
    long_desc <<-LONGDESC
        `uptimerobot_cmd add_new_monitor` will add new site for monitoring.
        Required options are: `--url`, `--contact-id`. You can get your
        desired CONTACT ID via `uptimerobot_cmd list_contacts` first column is the ID.
        `--name` is optional. It's the friendly name...
    LONGDESC
    def add_new_monitor
      my_options = {}
      my_options[:monitor_url] = options[:url]
      if ENV['UPTIMEROBOT_DEFAULT_CONTACT']
        my_options[:contact_id] = ENV['UPTIMEROBOT_DEFAULT_CONTACT']
      else
        my_options[:contact_id] = options[:contact_id] if options[:contact_id]
      end
      
      unless my_options[:contact_id]
        puts "Please provice --contact-id or set UPTIMEROBOT_DEFAULT_CONTACT environment variable"
        exit
      end
      
      my_options[:friendly_name] = options[:name] if options[:name]
      begin
        response = UptimerobotCmd.add_new_monitor(my_options)
        if response[0] == 200 and response[1] == "ok"
          message = "#{my_options[:monitor_url]} has been added." 
        else
          message = "Error. Response code: #{response[0]}, status: #{response[1]}"
        end
        puts message
      rescue UptimerobotCmd::OptionsError => e
        puts e
      end
    end
    
    option :monitor_id, :required => true
    desc "delete_monitor", "Delete monitor via given monitor_id"
    def delete_monitor
      my_options = {}
      my_options[:monitor_id] = options[:monitor_id]
      begin
        response = UptimerobotCmd.delete_monitor(my_options)
        if response[0] == 200 and response[1] == "ok"
          message = "Site has been deleted." 
        else
          message = "Error. Response code: #{response[0]}, status: #{response[1]}"
        end
        puts message
      rescue UptimerobotCmd::OptionsError => e
        puts e
      end
    end

  end
end