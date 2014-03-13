require 'spec_helper'

describe BankAccount do
  context "association" do
    it { should belong_to(:organization) }
  end

  context "validation" do
    it { should validate_presence_of(:name)                                  }
    it { should ensure_inclusion_of(:balance_currency).in_array(%w(USD RUB)) }
    it { should validate_presence_of(:balance_currency)                      }
  end
end
