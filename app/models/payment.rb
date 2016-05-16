class Payment < ActiveRecord::Base
  belongs_to :customer

  validates :card_type, :card_number, :verification_code, presence: true

  validates_format_of :valid_until,
                      :with => /\A\d{2}\/\d{2}\z/
  validate :expired?, :valid_card_number_length?,
           :valid_verification_code?

  def types
    ['VISA', 'Mastercard', 'Discover', 'American Express']
  end

  def valid_card_number_length? 
   card_number_string =  self.card_number.to_s
    case self.card_type
    when 'VISA'
      if (card_number_string.length != 13 && card_number_string.length != 16)
       errors.add(:card_number, "VISA cards must contain 13 or 16 numbers")
      end
    when 'American Express'
      if card_number_string.length != 15
        errors.add(:card_number, "American Express cards must contain 15 numbers")
      end
    when 'Mastercard', 'Discover'
      if card_number_string.length != 16
        errors.add(:card_number, "Mastercard and Discover card must contain 16 numbers")
      end
    else
      errors.add(:card_number, "must provide a valid card type")
    end
  end

  def expired?
    Date.parse(self.valid_until) rescue errors.add(:valid_until, "invalid date")
    if self.valid_until <= Date.today.strftime("%m/%y")
      errors.add(:valid_until, "Card expired")
    end
  end

  def valid_verification_code?
    if self.verification_code.to_s.length != 3
      errors.add(:verification_code, "verification code must contain 3 numbers")
    end
  end
end
