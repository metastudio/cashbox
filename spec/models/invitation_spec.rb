# == Schema Information
#
# Table name: invitations
#
#  id            :integer          not null, primary key
#  token         :string(255)      not null
#  email         :string(255)      not null
#  role          :string(255)      not null
#  invited_by_id :integer          not null
#  accepted      :boolean          default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe Invitation do
  context 'association' do
    it { is_expected.to delegate_method(:organization).to(:member) }

    it { is_expected.to belong_to(:member).with_foreign_key(:invited_by_id) }
    it { is_expected.to belong_to(:user).with_primary_key(:email).with_foreign_key(:email) }
  end
end
