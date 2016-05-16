class PaymentSerializer < ActiveModel::Serializer
  attributes :id, :card_type, :card_number, :verification_code, :valid_until
end
