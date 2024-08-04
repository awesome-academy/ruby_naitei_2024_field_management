class Rating < ApplicationRecord
  PERMITTED_ATTRIBUTES = %i(rating description).freeze

  belongs_to :user
  belongs_to :field
  has_many :reviews, foreign_key: "parent_rating_id", dependent: :destroy
end
