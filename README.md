# UptimerobotCmd

Command-line client for [Uptimerobot](https:uptimerobot.com) service.

## Installation

You can add this gem to your projects or you can access directly from
command-line. For command-line usage:

```bash
gem install uptimerobot_cmd
```

For library usage, add this line to your application's Gemfile:

```ruby
gem 'uptimerobot_cmd'
```

## Usage

You need to set an environment variable to use this mini tool. You need
Uptimerobot service’s APIKEY. Please set this variable;

```bash
export UPTIMEROBOT_APIKEY=YOUR_API_KEY
```

Also, you can set default contact ID for quick monitoring.

```bash
export UPTIMEROBOT_DEFAULT_CONTACT=CONTACT_ID
```

All commands:

```bash
Commands:
  uptimerobot_cmd add_new_monitor --contact-id=CONTACT_ID --url=URL  # Add new service for monitor
  uptimerobot_cmd delete_monitor --monitor-id=MONITOR_ID             # Delete monitor via given monitor_id
  uptimerobot_cmd help [COMMAND]                                     # Describe available commands or one specific command
  uptimerobot_cmd list_contacts                                      # List current contacts for monitors
  uptimerobot_cmd list_monitors                                      # List current monitors
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, 
run `bundle exec rake test` to run the tests. You can also run `bin/console` for an 
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, and then 
run `bundle exec rake release`, which will create a git tag for the version, 
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Running Tests

Run all tests via `bundle exec rake`. To run private tests only:

```bash
bundle exec rake TEST=test/private_test.rb 
```

Due to Security and Privacy, most of the test cases are private. You can find
example private tests under `test/` folder.

## TODO

- `add_new_monitor` will have more options/features...

## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/vigo/uptimerobot_cmd. This project is intended to be a safe, 
welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).

