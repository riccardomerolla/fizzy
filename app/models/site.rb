class Site < ApplicationRecord
  belongs_to :account

  has_many :reprocessing_cycles, dependent: :destroy
  has_many :contracts, dependent: :destroy
  has_many :csv_imports, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :account_id }
  validates :timezone, presence: true

  scope :alphabetically, -> { order(:name) }
end
