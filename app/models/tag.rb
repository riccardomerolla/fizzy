class Tag < ApplicationRecord
  include Filterable

  has_many :taggings, dependent: :destroy
  has_many :cards, through: :taggings

  validates :title, format: { without: /\A#/ }
  normalizes :title, with: -> { it.downcase }

  scope :alphabetically, -> { order("lower(title)") }

  def hashtag
    "#" + title
  end
end
