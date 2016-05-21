class OrderStatus < ActiveRecord::Base

  validates :description, presence: true

  searchkick match: :word_start, searchable: [:description]

  def make_default!
    OrderStatus.update_all(default: false)
    update!(default: true)
  end

  def self.default
    find_by(default: true)
  end
end
