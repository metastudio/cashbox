require 'spec_helper'

describe BankAccount do
  context "association" do
    it { should belong_to(:organization) }
  end

  context "validation" do
    it { should validate_presence_of(:name)             }
    it { should validate_presence_of(:balance_cents)    }
    it { should validate_presence_of(:balance_currency) }
  end
end

