require "test_helper"

class Account::SignalAccountTest < ActiveSupport::TestCase
  setup do
    @account = accounts("37s")
  end

  test "belongs to a signal_account via a shared queenbee_id" do
    assert_not_nil @account.queenbee_id
    assert_equal @account.queenbee_id, Account.new(signal_account: @account.signal_account).queenbee_id
    assert_equal @account.signal_account, Account.new(queenbee_id: @account.queenbee_id).signal_account
  end
end
