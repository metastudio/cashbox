module FeatureMacros
  module Invitation
    def invite_new_user(inviter, role, email)
      sign_in inviter
      visit new_invitation_path
      fill_in 'Email', with: email
      select role.capitalize, from: 'Role'
      click_on 'Invite'
      sign_out
    end

    def invite_existing_user(inviter, role, user)
      sign_in inviter
      visit new_invitation_path
      fill_in 'Email', with: user.email
      select role.capitalize, from: 'Role'
      click_on 'Invite'
      sign_out
    end


  end
end

RSpec.configure do |config|
  config.include FeatureMacros::Invitation, type: :feature
end
