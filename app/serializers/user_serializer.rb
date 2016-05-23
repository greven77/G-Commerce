class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :user_role
  self.root = false
end
