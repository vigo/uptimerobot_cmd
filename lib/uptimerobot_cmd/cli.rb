require 'thor'
require 'uptimerobot_cmd'
require 'uri'

module UptimerobotCmd
  class CLI < Thor
    
    option :color, :type => :boolean
    desc "list", "List current monitors"
    long_desc <<-LONGDESC
      \x5$ uptimerobot_cmd list
      \x5$ uptimerobot_cmd list --color
    LONGDESC
    def list
      ENV['UPTIMEROBOT_COLORIZE'] = '1' if options[:color]
      puts UptimerobotCmd.get_list_monitors
    end
    
    option :color, :type => :boolean
    desc "contacts", "List current contacts for monitors"
    long_desc <<-LONGDESC
      \x5$ uptimerobot_cmd contacts
      \x5$ uptimerobot_cmd contacts --color
    LONGDESC
    def contacts
      ENV['UPTIMEROBOT_COLORIZE'] = '1' if options[:color]
      puts UptimerobotCmd.list_alert_contacts
    end
    
    option :contact
    option :name
    desc "add", "Add new service for monitoring"
    long_desc <<-LONGDESC
      \x5$ uptimerobot_cmd add http://example.com --contact=1234567
      \x5$ uptimerobot_cmd add http://example.com --name=Example --contact=1234567
      \x5$ uptimerobot_cmd add http://example.com --name="Example Website" --contact=1234567
    LONGDESC
    def add(url)
      my_options = {}
      my_options[:monitor_url] = url if url =~ /\A#{URI::regexp}\z/
      unless my_options[:monitor_url]
        puts "Please enter valid url. Example: http://example.com or https://example.com"
        exit
      end
      my_options[:contact_id] = options[:contact] || ENV['UPTIMEROBOT_DEFAULT_CONTACT'] || nil
      unless my_options[:contact_id]
        puts "Please set contact or set UPTIMEROBOT_DEFAULT_CONTACT environment variable"
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
    
    desc "delete", "Delete monitor"
    def delete(input)
      search = UptimerobotCmd.search_in_monitors(input)
      puts search
      # monitors = UptimerobotCmd.get_monitors
      # puts monitors
      # is_url = true if name_or_url =~ /\A#{URI::regexp}\z/
    end
    
    option :color, :type => :boolean
    desc "search NAME or URL", "Search in monitored services"
    def search(input)
      ENV['UPTIMEROBOT_COLORIZE'] = '1' if options[:color]
      puts UptimerobotCmd.get_search_results(input)
    end
    
    # option :monitor_id, :required => true
    # desc "delete_monitor", "Delete monitor via given monitor_id"
    # def delete_monitor
    #   my_options = {}
    #   my_options[:monitor_id] = options[:monitor_id]
    #   begin
    #     response = UptimerobotCmd.delete_monitor(my_options)
    #     if response[0] == 200 and response[1] == "ok"
    #       message = "Site has been deleted."
    #     else
    #       message = "Error. Response code: #{response[0]}, status: #{response[1]}"
    #     end
    #     puts message
    #   rescue UptimerobotCmd::OptionsError => e
    #     puts e
    #   end
    # end
    
    
    

  end
end