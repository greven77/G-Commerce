class Customer < ActiveRecord::Base
  belongs_to :user

  has_many :feedbacks, dependent: :destroy
  has_many :orders, dependent: :destroy

  has_one :billing_address, :class_name => "Address", dependent: :destroy
  has_one :shipping_address, :class_name => "Address", dependent: :destroy

  has_one :payment_method, :class_name => "Payment", dependent: :destroy

  validates :name, :phone, :billing_address, :shipping_address, :payment_method,
            presence: true
  max_paginates_per 50

  accepts_nested_attributes_for :feedbacks, :orders, :billing_address,
                                :shipping_address, :payment_method, allow_destroy: true

  searchkick match: :word_start, searchable: [:name, :email]
  after_commit :reindex_user

  def reindex_user
    user.reindex
  end

  def search_data
    {
      name: name,
      email: user.email,
      created_at: created_at,
      autocomplete_item: autocomplete_item
    }
  end

  def autocomplete_item
    "#{self.name}, #{self.user.email}"
  end
end
