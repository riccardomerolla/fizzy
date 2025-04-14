require "test_helper"

class EventSummaryTest < ActiveSupport::TestCase
  test "body" do
    assert_equal "Added by David. Assigned to JZ.", event_summaries(:logo_initial_activity).body
    assert_equal "Assigned to Kevin.", event_summaries(:logo_second_activity).body
    assert_equal "Added by Kevin.", event_summaries(:text_initial_activity).body
  end
end
