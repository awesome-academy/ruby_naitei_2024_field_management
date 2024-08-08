class User < ApplicationRecord
  PERMITTED_ATTRIBUTES = %i(name email password password_confirmation).freeze
  RESET_PASSWORD_ATTRIBUTES = %i(password password_confirmation).freeze

  attr_accessor :activation_token, :remember_token, :reset_token

  has_many :vouchers, dependent: :destroy
  has_many :favourite_relationships, class_name: FavouriteField.name,
                                    dependent: :destroy
  has_many :favourite_fields, through: :favourite_relationships,
source: :field
  has_many :order_relationships, class_name: OrderField.name,
                                      dependent: :destroy
  has_many :order_fields, through: :order_relationships,
source: :field
  has_many :ratings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [Settings.limit_img_size,
                                                  Settings.limit_img_size]
  end

  validates :name, presence: true, length: {maximum: Settings.max_name_length}
  validates :email, presence: true,
                    length: {maximum: Settings.max_length_255},
                    format: {with: Regexp.new(Settings.valid_email_regex, "i")},
                    uniqueness: true
  has_secure_password
  validates :password, presence: true,
                    length: {minimum: Settings.min_password_length},
                    allow_nil: true
  validate :password_complexity

  scope :search_by_name, lambda {|name|
    where("name LIKE ?", "%#{name}%") if name.present?
  }
  scope :search_by_email, lambda {|email|
    where("email LIKE ?", "%#{email}%") if email.present?
  }
  scope :search_by_status, lambda {|activated|
    if activated == "false"
      where(activated: [nil, false])
    elsif activated == "true"
      where(activated: true)
    end
  }
  scope :order_by, lambda {|attribute = :id, direction = :asc|
                     order(Arel.sql("#{attribute} #{direction}"))
                   }

  before_save :downcase_email
  before_create :create_activation_digest

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
    remember_digest
  end

  def authenticated? attribute, token
    digest = public_send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def session_token
    remember_digest || remember
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.hours_expired.hours.ago
  end

  def get_remain_account amount
    money - amount
  end

  def add_favourite_field field
    favourite_fields << field
  end

  def remove_favourite_field field
    favourite_fields.delete field
  end

  def favourite_field? field
    favourite_fields.include? field
  end

  def order_field? field
    order_relationships.approved.exists? field_id: field.id
  end

  def rating_field? field
    ratings.exists? field_id: field.id
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end

  def password_complexity
    return if password.blank?

    complexity_requirements = [
      Settings.password.lowercase,
      Settings.password.uppercase,
      Settings.password.digit,
      Settings.password.special
    ]

    types = complexity_requirements.count do |requirement|
      password.match?(Regexp.new(requirement))
    end

    return unless types < Settings.min_password_types

    errors.add :base, I18n.t("users.create.password_complexity")
  end

  def create_activity
    create_action(:created, self)
  end

  def update_activity
    create_action(:updated, self)
  end
end
