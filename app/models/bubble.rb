class Bubble < ApplicationRecord
  include Assignable, Colored, Poppable, Searchable, Taggable

  belongs_to :bucket
  belongs_to :creator, class_name: "User", default: -> { Current.user }

  has_many :comments, dependent: :destroy
  has_many :boosts, dependent: :destroy

  has_one_attached :image, dependent: :purge_later

  scope :reverse_chronologically, -> { order(created_at: :desc, id: :desc) }
  scope :ordered_by_activity, -> { left_joins(:comments, :boosts).group(:id).order(Arel.sql("COUNT(comments.id) + COUNT(boosts.id) DESC")) }

  searchable_by :title, using: :bubbles_search_index

  scope :mentioning, ->(query) do
    bubbles = search(query).select(:id).to_sql
    comments = Comment.search(query).select(:bubble_id).to_sql

    left_joins(:comments)
      .where("bubbles.id in (#{bubbles}) or comments.bubble_id in (#{comments})")
      .distinct
  end
end
