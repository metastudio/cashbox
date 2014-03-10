require 'spec_helper'

describe Invoice do
  context "association" do
    it { should belong_to(:organization) }
    it { should have_many(:transactions) }
  end

  context "validation" do
    it { should validate_presence_of(:name)             }
    it { should validate_presence_of(:balance_cents)    }
    it { should validate_presence_of(:balance_currency) }
  end
end

