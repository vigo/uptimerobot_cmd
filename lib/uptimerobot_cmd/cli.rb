require 'thor'
require 'uptimerobot_cmd'
require 'uri'

module UptimerobotCmd
  class CLI < Thor
    class_option :color, :type => :boolean

    desc "list", "List current monitors"
    long_desc <<-LONGDESC
      List current monitored services.\n
      
      $ uptimerobot_cmd list\n
      $ uptimerobot_cmd list --color
    LONGDESC
    def list
      ENV['UPTIMEROBOT_COLORIZE'] = '1' if options[:color]
      monitors = UptimerobotCmd.get_monitors
      table_title = 'Monitoring %d site(s)' % monitors.count
      puts print_monitors(monitors, table_title)
    end

    desc "contacts", "List current contacts for monitors"
    long_desc <<-LONGDESC
      List available contact information.\n

      $ uptimerobot_cmd contacts\n
      $ uptimerobot_cmd contacts --color
    LONGDESC
    def contacts
      ENV['UPTIMEROBOT_COLORIZE'] = '1' if options[:color]
      contacts = UptimerobotCmd.get_alert_contacts
      table_title = 'Listing %d contact(s)' % contacts.count
      puts print_contacts(contacts, table_title)
    end
    
    option :contact, :banner => "<contact_id>"
    option :name, :banner => "<friendly name>"
    desc "add", "Add new service for monitoring"
    long_desc <<-LONGDESC
      You need to provide `--contact` option or must set `UPTIMEROBOT_DEFAULT_CONTACT`
      environment variable.

      $ uptimerobot_cmd add http://example.com --contact=1234567\n
      $ uptimerobot_cmd add http://example.com --name=Example --contact=1234567\n
      $ uptimerobot_cmd add http://example.com --name="Example Website" --contact=1234567
    LONGDESC
    def add(url)
      ENV['UPTIMEROBOT_COLORIZE'] = '1' if options[:color]

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

      duplicate_entries = UptimerobotCmd.search_in_monitors(url)
      if duplicate_entries.count > 0
        table_title = 'Found duplicate %d monitor(s)' % duplicate_entries.count
        puts print_monitors(duplicate_entries, table_title)
        exit
      else
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
    end
    
    desc "delete", "Delete monitor"
    def delete(input)
      ENV['UPTIMEROBOT_COLORIZE'] = '1' if options[:color]
      search = UptimerobotCmd.search_in_monitors(input)
      delete_id = nil
      if search.count > 1
        puts print_monitors(search, 'Found %d monitor(s)' % search.count)
        ask_delete_id = ask("Please enter ID number:").to_i
        delete_id = ask_delete_id if ask_delete_id > 0
      else
        ask_user = "You are going to delete %{name} [%{url}]" % {
          name: search.first['friendlyname'],
          url: search.first['url'],
        }
        result = ask(ask_user, :limited_to => ['y', 'n'])
        delete_id = search.first['id'] if result == 'y'
      end
      
      if delete_id
        response = UptimerobotCmd.delete_monitor(monitor_id: delete_id)
        if response[0] == 200 and response[1] == "ok"
          message = "Site has been deleted."
        else
          message = "Error. Response code: #{response[0]}, status: #{response[1]}"
        end
        puts message
      else
        puts "Delete canceled..."
      end
    end
    
    desc "search NAME or URL", "Search in monitored services"
    def search(input)
      ENV['UPTIMEROBOT_COLORIZE'] = '1' if options[:color]
      results = UptimerobotCmd.search_in_monitors(input)
      table_title = 'Found %d monitor(s)' % results.count
      puts print_monitors(results, table_title)
    end
    
    no_commands do
      def print_contacts(contacts, table_title)
        table_title = set_color(table_title, :yellow) if ENV['UPTIMEROBOT_COLORIZE']
        rows = []
        contacts.each do |contact|
          contact_id = contact['id']
          contact_id = set_color(contact_id, :green) if ENV['UPTIMEROBOT_COLORIZE']
          contact_info = contact['value']
          contact_info = set_color(contact_info, :white) if ENV['UPTIMEROBOT_COLORIZE']
          rows << [contact_id, contact_info]
        end
        Terminal::Table.new :headings => ['ID', 'Info'],
                            :rows => rows,
                            :title => table_title
      end
      
      def print_monitors(monitors, table_title)
        table_title = set_color(table_title, :yellow) if ENV['UPTIMEROBOT_COLORIZE']
        rows = []
        monitors.each do |monitor|
          monitor_id = monitor['id']
          monitor_id = set_color(monitor_id, :green) if ENV['UPTIMEROBOT_COLORIZE']
          status_data = ::UptimerobotCmd.human_readable_status(monitor['status'])
          status = status_data[0]
          status = set_color(status, status_data[1], :bold) if ENV['UPTIMEROBOT_COLORIZE']
          friendly_name = monitor['friendlyname']
          friendly_name = set_color(friendly_name, :white) if ENV['UPTIMEROBOT_COLORIZE']
          url = monitor['url']
          url = set_color(url, :cyan) if ENV['UPTIMEROBOT_COLORIZE']
          rows << [monitor_id, status, friendly_name, url]
        end
        Terminal::Table.new :headings => ['ID', 'Status', 'Name', 'Url'],
                            :rows => rows,
                            :title => table_title
      end
    end

  end
end