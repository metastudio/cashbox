require 'spec_helper'

describe Transaction do
  context "association" do
    it { should belong_to(:category) }
    it { should belong_to(:bank_account)  }
  end

  context "validation" do
    it { should validate_presence_of(:amount_currency) }
    it { should ensure_inclusion_of(:amount_currency).in_array(%w(USD RUB)) }
    it { should validate_presence_of(:category_id)     }
    it { should validate_presence_of(:bank_account_id) }
  end
end
