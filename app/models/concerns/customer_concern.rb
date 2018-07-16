# frozen_string_literal: true

module CustomerConcern
  extend ActiveSupport::Concern

  included do
    validates :customer_name, length: { maximum: 255 }
  end

  module ClassMethods
    def customer_concern_callbacks
      before_validation :find_customer
    end
  end

  def customer_name
    @customer_name || customer&.name
  end

  def customer_name=(value)
    attribute_will_change!('customer_name') if @customer_name != value
    @customer_name = value
  end

  private

  def find_customer
    return if customer_name.blank?

    self.customer = Customer.find_or_initialize_by(name: customer_name, organization_id: organization.id)
  end
end
