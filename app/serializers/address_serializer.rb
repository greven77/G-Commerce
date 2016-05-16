class AddressSerializer < ActiveModel::Serializer
  attributes :id, :street, :post_code, :city
  has_one :country
end
