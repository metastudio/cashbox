# == Schema Information
#
# Table name: invitations
#
#  id            :integer          not null, primary key
#  token         :string(255)      not null
#  email         :string(255)      not null
#  role          :string
#  accepted      :boolean          default(FALSE)
#  invited_by_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  type          :string
#

require 'rails_helper'

describe OrganizationInvitation do
  context 'association' do
    it { is_expected.to delegate_method(:organization).to(:invited_by) }

    it { is_expected.to belong_to(:invited_by).class_name('Member') }
    it { is_expected.to belong_to(:user).with_primary_key(:email).with_foreign_key(:email) }
  end
end
