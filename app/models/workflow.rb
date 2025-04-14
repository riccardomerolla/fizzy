class Workflow < ApplicationRecord
  has_many :stages, dependent: :delete_all
end
