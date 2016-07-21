require 'test_helper'

class UptimerobotCmdTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::UptimerobotCmd::VERSION
  end

  def test_get_monitors
#    skip "test this later"
    monitors = ::UptimerobotCmd.get_monitors

    refute_empty monitors
    assert_instance_of Array, monitors
    assert_equal true, monitors[0].has_key?('id')
    assert_equal true, monitors[0].has_key?('url')
  end
  
  def test_get_alert_contacts
#    skip "test this later"
    contacts = ::UptimerobotCmd.get_alert_contacts
    refute_empty contacts
    assert_instance_of Array, contacts
    assert_equal true, contacts[0].has_key?('id')
    assert_equal true, contacts[0].has_key?('value')
    assert_equal true, contacts[0].has_key?('type')
  end
  
  def test_get_alert_contacts_for_bilgi
    skip "this test works with only with UPTIMEROBOT_BILGI_APIKEY" unless ENV['UPTIMEROBOT_BILGI_APIKEY']
    contacts = ::UptimerobotCmd.get_alert_contacts
    webteam_user = contacts.select{|c| c['friendlyname']  == 'webteam@bilgi.edu.tr'}.first
    vigo_user = contacts.select{|c| c['friendlyname']  == 'vigo'}.first

    assert_instance_of Hash, webteam_user
    assert_instance_of Hash, vigo_user

    assert_equal '0292994', webteam_user['id']
    assert_equal '2412466', vigo_user['id']
  end
end
