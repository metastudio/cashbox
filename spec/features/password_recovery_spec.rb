require 'spec_helper'

describe 'password recovery' do
  let!(:user) { create :user }
  let(:email) { user.email }

  subject{ page }

  before :each do
    visit new_user_session_path
    click_on 'Forgot your password?'
    fill_in 'Email', with: email
    click_on 'Send me reset password instructions'
  end

  context "with right email" do
    it "shows notice" do
      expect(subject).to have_content('You will receive an email with instructions on how to reset your password in a few minutes')
    end

    it "sends email with reset password insturctions" do
      open_email(email)
      expect(current_email.subject).to eq 'Reset password instructions'
    end

    context "after open link in email" do
      before :each do
        open_email(email)
        current_email.click_link "Change my password"
      end

      it "shows form to enter new password" do
        expect(subject).to have_field("New password")
      end

      context "and enter new password" do
        before :each do
          fill_in "New password", with: "newpassword"
          fill_in "Confirm your new password", with: "newpassword"
          click_on "Change my password"
        end

        it "shows successfull notice" do
          expect(subject).to have_content("Your password has been changed successfully")
        end
      end
    end
  end

  context "with wrong email" do
    let(:email) { "wrong-email@cashbox.dev" }

    it "shows not found error for email" do
      expect(subject).to have_inline_error('not found').for_field('Email')
    end
  end
end
