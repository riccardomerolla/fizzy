class Account < ApplicationRecord
  include Entropic, Joinable, SignalAccount

  has_many_attached :uploads
end
