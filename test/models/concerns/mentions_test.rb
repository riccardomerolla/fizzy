require "test_helper"

class MentionsTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "create mentions from plain text mentions" do
    assert_difference -> { Mention.count }, +1 do
      perform_enqueued_jobs only: Mention::CreateJob do
        collections(:writebook).cards.create title: "Cleanup", description: "Did you finish up with the cleanup, @david?"
      end
    end
  end

  test "create mentions from rich text mentions" do
    assert_difference -> { Mention.count }, +1 do
      perform_enqueued_jobs only: Mention::CreateJob do
        attachment = ActionText::Attachment.from_attachable(users(:david))
        collections(:writebook).cards.create title: "Cleanup", description: "Did you finish up with the cleanup, #{attachment.to_html}?"
      end
    end
  end

  test "can't mention users that don't have access to the collection" do
    collections(:writebook).update! all_access: false
    collections(:writebook).accesses.revoke_from(users(:david))

    assert_no_difference -> { Mention.count }, +1 do
      perform_enqueued_jobs only: Mention::CreateJob do
        attachment = ActionText::Attachment.from_attachable(users(:david))
        collections(:writebook).cards.create title: "Cleanup", description: "Did you finish up with the cleanup, #{attachment.to_html}?"
      end
    end
  end

  test "mentionees are added as watchers of the card" do
    perform_enqueued_jobs only: Mention::CreateJob do
      card = collections(:writebook).cards.create title: "Cleanup", description: "Did you finish up with the cleanup @kevin?"
      assert card.watchers.include?(users(:kevin))
    end
  end
end
