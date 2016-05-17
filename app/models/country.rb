class Country < ActiveRecord::Base
  has_many :addresses, dependent: :nullify

  validates :name, presence: true

  max_paginates_per 50
end
