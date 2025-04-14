class Account < ApplicationRecord
  include Joinable

  has_many_attached :uploads
end
