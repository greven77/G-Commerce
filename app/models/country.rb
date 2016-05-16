class Country < ActiveRecord::Base
  has_many :addresses, dependent: :nullify

  validates :name, presence: true
end
