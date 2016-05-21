class Role < ActiveRecord::Base
  has_many :users

  validates :name, presence: true

  searchkick match: :word_start, searchable: [:name]

  def to_s
    self.name
  end
end
