# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  full_name              :string(255)      not null
#

require 'rails_helper'

describe User do
  context "association" do
    it { should have_one(:profile).dependent(:destroy) }
    it { should have_many(:own_organizations).class_name('Organization').through(:members).dependent(:restrict_with_error) }
    it { should have_many(:members).dependent(:destroy) }
    it { should have_many(:organizations).through(:members) }
    it { should have_many(:transactions).dependent(:nullify) }
  end

  context "validations" do
    subject { create :user }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should_not allow_value("bad email").for(:email) }
    it { should allow_value("email@test.com").for(:email) }
  end

  context "callback" do
    describe "#build_profile" do
      let(:user) { build :user, profile: nil }
      it "creates profile" do
        expect {
          user.save
        }.to change(user, :profile).from(nil)
      end

      it "creates profile" do
        user.save
        expect(user.profile).to be_persisted
      end
    end
  end
end
