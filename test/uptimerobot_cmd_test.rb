require 'test_helper'

class UptimerobotCmdTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::UptimerobotCmd::VERSION
  end
    
  def test_get_monitors
    monitors = ::UptimerobotCmd.get_monitors

    refute_empty monitors
    assert_instance_of Array, monitors
    assert_equal true, monitors[0].has_key?('id')
    assert_equal true, monitors[0].has_key?('url')
  end
end
