require 'rails_helper'

describe 'delete member' do
  let(:user)       { create :user }
  let(:other_user) { create :user }
  let!(:org)       { create :organization }

  context 'when member with owner role' do
    let!(:member_owner) { create :member, :owner, user: user, organization: org }

    before do
      sign_in member_owner.user
      visit members_path
    end

    it 'owner can not remove yourself' do
      expect(page).to_not have_content('Remove')
    end

    context 'owner can remove members with admin role', js: true do
      let!(:member_admin) { create :member, :admin, user: other_user, organization: org }

      before do
        visit members_path
        click_on 'Remove'
      end

      it { expect(page).to_not have_content(member_admin.user_full_name) }
    end

    context 'owner can remove members with user role', js: true do
      let!(:member_user) { create :member, :user, user: other_user, organization: org }

      before do
        visit members_path
        click_on 'Remove'
      end

      it { expect(page).to_not have_content(member_user.user_full_name) }
    end
  end

  context 'when member with admin role' do
    let!(:member_admin) { create :member, :admin, user: user, organization: org }

    before do
      sign_in member_admin.user
      visit members_path
    end

    it 'admin can not remove yourself' do
      expect(page).to_not have_content('Remove')
    end

    context 'admin can not remove members with owner role' do
      let!(:member_owner) { create :member, :owner, user: other_user, organization: org }

      it { expect(page).to_not have_content('Remove') }
    end

    context 'admin can remove other members with admin role', js: true do
      let!(:other_member_admin) { create :member, :admin, user: other_user, organization: org }

      before do
        visit members_path
        click_on 'Remove'
      end

      it { expect(page).to_not have_content(other_member_admin.user_full_name) }
    end

    context 'admin can remove members with user role', js: true do
      let!(:member_user) { create :member, :user, user: other_user, organization: org }

      before do
        visit members_path
        click_on 'Remove'
      end

      it { expect(page).to_not have_content(member_user.user_full_name) }
    end
  end

  context 'when member with user role' do
    let!(:member_user) { create :member, :user, user: user, organization: org }

    before do
      sign_in member_user.user
      visit members_path
    end

    it 'user can not remove yourself' do
      expect(page).to_not have_content('Remove')
    end

    context 'user can not remove members with owner role' do
      let!(:member_owner) { create :member, :owner, user: other_user, organization: org }

      it { expect(page).to_not have_content('Remove') }
    end

    context 'user can not remove members with admin role' do
      let!(:member_admin) { create :member, :admin, user: other_user, organization: org }

      it { expect(page).to_not have_content('Remove') }
    end

    context 'user can not remove other members with user role' do
      let!(:other_member_user) { create :member, :user, user: other_user, organization: org }

      it { expect(page).to_not have_content('Remove') }
    end
  end
end
