# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id               :integer          not null, primary key
#  name             :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  default_currency :string(255)      default("USD")
#

class OrganizationSerializer < ApplicationSerializer
  attributes :id, :name, :default_currency
end
