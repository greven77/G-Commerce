class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :password_confirmation, presence: true, on: [:create]
#  validates :role, presence: true
  belongs_to :role
  before_create :set_default_role
  before_save :ensure_authentication_token

  def admin?
    user_role == 'admin'
  end

  def user_role
    self.role.name if self.role
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def clear_authentication_token
    User.skip_callback(:save, :before, :ensure_authentication_token)
    self.authentication_token = nil
    self.save
    User.set_callback(:save, :before, :ensure_authentication_token)
  end

  private

  def set_default_role
    self.role ||= Role.find_by_name('customer')
  end

  # generates authentication token and ensures that it is unique
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
