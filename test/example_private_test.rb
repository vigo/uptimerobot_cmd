require 'test_helper'

# Please fix the test according to your credentials

class UptimerobotCmdTest < Minitest::Test
  def test_get_alert_contacts_for_YOU
    skip # delete this if you want to run it
    contacts = ::UptimerobotCmd.get_alert_contacts
    your_user = contacts.select{|c| c['friendlyname']  == 'WHAT_TO_EXCPECT'}.first

    assert_instance_of Hash, your_user
    assert_equal 'CONTACT_ID', your_user['id']
  end

  def test_get_monitors_for_you
    skip # delete this if you want to run it
    monitors = ::UptimerobotCmd.get_monitors

    assert_instance_of Array, monitors
    assert_match (/111111111/), monitors.to_s        # GIVE_MONITOR_ID_HERE
    assert_match (/google.com/), monitors.to_s       # GIVE_URL_HERE
  end

  def test_add_new_monitor_for_you_without_options
    skip # delete this if you want to run it
    assert_raises(::UptimerobotCmd::OptionsError) { ::UptimerobotCmd.add_new_monitor }
  end

  def test_add_new_monitor_for_you_without_monitor_url
    skip # delete this if you want to run it
    assert_raises(::UptimerobotCmd::OptionsError) { ::UptimerobotCmd.add_new_monitor(contact_id: '1234567') }
  end

  def test_add_new_monitor_for_you_without_contact_id
    skip # delete this if you want to run it
    # buffer = ENV['UPTIMEROBOT_DEFAULT_CONTACT']
    ENV.delete('UPTIMEROBOT_DEFAULT_CONTACT')
    assert_raises(::UptimerobotCmd::OptionsError) { ::UptimerobotCmd.add_new_monitor(monitor_url: 'https://google.com') }
  end

  def test_add_new_monitor_for_you
    skip # delete this if you want to run it
    result = ::UptimerobotCmd.add_new_monitor(monitor_url: 'https://google.com', contact_id: '1234567')
    assert_instance_of Array, result
    assert_equal 200, result[0]
    assert_equal "ok", result[1]
  end
  
  def test_delete_monitor_for_you_without_options
    skip # delete this if you want to run it
    assert_raises(::UptimerobotCmd::OptionsError) { ::UptimerobotCmd.delete_monitor }
  end

  def test_delete_monitor_for_you
    skip # delete this if you want to run it
    result = ::UptimerobotCmd.delete_monitor(monitor_id: '1234567')
    assert_instance_of Array, result
    assert_equal 200, result[0]
    assert_equal "ok", result[1]
  end
end
