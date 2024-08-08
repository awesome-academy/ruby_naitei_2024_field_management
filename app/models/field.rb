class Field < ApplicationRecord
  include UsersHelper

  CREATE_ATTRIBUTES = %i(field_type_id name default_price open_time
close_time description image).freeze

  belongs_to :field_type
  has_many :unavailable_field_schedules, dependent: :destroy
  has_many :favourite_relationships, class_name: FavouriteField.name,
  dependent: :destroy
  has_many :favourite_users, through: :favourite_relationships,
source: :user
  has_many :order_relationships, class_name: OrderField.name,
    dependent: :destroy
  has_many :ordered_users, through: :order_relationships,
source: :user
  has_many :ratings, dependent: :destroy
  has_many :activities, as: :trackable, dependent: nil
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [Settings.limit_img_size,
                                                  Settings.limit_img_size]
  end

  validates :field_type_id, :name, :default_price, :open_time, :close_time,
            presence: true
  validates :name, uniqueness: {scope: :field_type_id},
                    length: {maximum: Settings.max_name_length}
  validates :description, length: {maximum: Settings.max_length_255}
  validates :image, content_type: {in: Settings.image_format.split(","),
                                   message: I18n.t(
                                     "fields.errors.invalid_img_format"
                                   )},
                    size: {less_than: Settings.max_img_size.megabytes,
                           message: I18n.t(
                             "fields.errors.too_large_img_size"
                           )}
  validate :validate_time

  scope :name_like, lambda {|name|
                      where("name LIKE ?", "%#{name}%") if name.present?
                    }
  scope :order_by, lambda {|attribute, direction|
                     order(attribute || :created_at => direction || :asc)
                   }
  scope :most_rated, (lambda do
    left_outer_joins(:ratings)
      .group(:id)
      .order("AVG(ratings.rating) DESC")
      .includes(image_attachment: :blob)
  end)
  scope :field_type, lambda {|field_type_id|
                       if field_type_id.present? && field_type_id != "all"
                         where(field_type_id:)
                       end
                     }
  scope :favourite_by_current_user, ->(ids){where id: ids if ids.present?}

  after_create :create_activity
  after_update :update_activity
  before_destroy :destroy_activity

  def average_rating
    ratings.average(:rating).to_f.round(1)
  end

  def has_any_uncompleted_order?
    order_relationships.approved.each do |order|
      return true if order.uncomplete?
    end
    false
  end

  private

  def validate_time
    return if close_time.nil? || open_time.nil? || close_time > open_time

    errors.add :base, I18n.t("fields.errors.valid_time")
  end

  def create_activity
    create_action(admin, :created, self)
  end

  def update_activity
    create_action(admin, :updated, self)
  end

  def destroy_activity
    create_action(admin, :deleted, self)
  end
end
