require 'spec_helper'

describe Transaction do
  context "association" do
    it { should belong_to(:category) }
    it { should belong_to(:invoice)  }
  end

  context "validation" do
    it { should validate_presence_of(:amount_cents)    }
    it { should validate_presence_of(:amount_currency) }
    it { should validate_presence_of(:category_id)     }
    it { should validate_presence_of(:invoice_id)      }
  end
end
