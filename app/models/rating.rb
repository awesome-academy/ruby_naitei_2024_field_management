class Rating < ApplicationRecord
  PERMITTED_ATTRIBUTES = %i(rating description).freeze

  belongs_to :user
  belongs_to :field
  has_many :reviews, foreign_key: "parent_rating_id", dependent: :destroy
  has_many :activities, as: :trackable, dependent: nil

  validates :description, presence: true,
                          length: {maximum: Settings.max_length_255}

  scope :lastest, ->{order created_at: :desc}

  after_create :create_activity
  after_update :update_activity
  before_destroy :destroy_activity

  private

  def create_activity
    create_action(user, :created, self)
  end

  def update_activity
    create_action(user, :updated, self)
  end

  def destroy_activity
    create_action(user, :deleted, self)
  end
end
