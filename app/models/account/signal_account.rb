module Account::SignalAccount
  extend ActiveSupport::Concern

  included do
    # TODO: remove the "optional: true" once we've populated the accounts properly
    belongs_to :signal_account, class_name: "SignalId::Account", primary_key: :queenbee_id, foreign_key: :queenbee_id, optional: true
  end
end
