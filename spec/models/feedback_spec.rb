require 'rails_helper'

RSpec.describe Feedback, type: :model do
  it { should belong_to :product }
  it { should belong_to :user }
  it { should validate_presence_of :comment }
  it { should validate_presence_of :rating }
  it { should validate_presence_of :product_id }
  it { should validate_presence_of :user_id }
end
