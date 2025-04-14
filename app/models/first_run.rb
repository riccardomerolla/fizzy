class FirstRun
  def self.create!(user_attributes)
    Account.create!(name: "Fizzy")
    Closure::Reason.create_defaults
    User.member.create!(user_attributes)
  end
end
