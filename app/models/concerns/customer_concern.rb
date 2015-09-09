module CustomerConcern
  extend ActiveSupport::Concern

  included do
    attr_accessor :customer_name

    validates :customer_name, length: { maximum: 255 }

    def customer_name=(value)
      attribute_will_change!("customer_name") if @customer_name != value
      @customer_name = value
    end
  end

  module ClassMethods
    def customer_concern_callbacks
      before_validation :find_customer, if: Proc.new{ self.customer_name.present? }
    end
  end

  private

  def find_customer
    self.customer = Customer.find_or_initialize_by(name: customer_name, organization_id: self.organization.id)
  end
end
