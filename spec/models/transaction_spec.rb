require 'spec_helper'

describe Transaction do
  context "association" do
    it { should belong_to(:category) }
    it { should belong_to(:bank_account)  }
    it { should have_one(:organization).through(:bank_account) }
  end

  context "validation" do
    it { should validate_presence_of(:category)     }
    it { should validate_presence_of(:bank_account) }
  end
end
