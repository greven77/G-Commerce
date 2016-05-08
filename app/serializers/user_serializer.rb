class UserSerializer < ActiveModel::Serializer
  attributes :id, :email
  has_many :feedbacks
  belongs_to :role_id
end
