require 'spec_helper'

describe 'Change profile' do
  let(:email) { generate :email }
  let(:full_name) { generate :full_name }
  let(:current_password) { generate :password }
  let(:password) { generate :password }
  let(:password_confirmation) { password }
  let(:phone_number) { generate :phone_number }
  let(:user) { create :user, password: current_password }

  context 'when user is signed in' do
    before { sign_in user }

    after { Capybara.reset_sessions! }

    subject { page }

    it { expect(subject).to have_link('Edit Profile') }

    context 'profile editing' do
      before do
        click_on 'Edit Profile'
        fill_in 'Full name', with: full_name
        fill_in 'Phone number', with: phone_number
        click_on 'Update profile'
      end

      context 'with valid params' do
        it { expect(subject).to have_content 'Your account has been updated successfully.' }

        describe 'updated profile' do
          subject { user.reload }

          it { expect(subject.full_name).to eq full_name }
          it { expect(subject.profile.phone_number).to eq phone_number }
        end
      end

      context 'without full name' do
        let(:full_name) { nil }
        it { expect(page).to have_inline_error('can\'t be blank').for_field('Full name') }
      end
    end

    context 'password changing' do
      before do
        click_on 'Edit Profile'
      end

      context "with password provided" do
        context "with valid params" do
          let(:new_email) { generate :email }
          before do
            fill_in 'Email', with: new_email
            fill_in 'Current password', with: current_password
            click_on 'Update account'
          end

          describe 'updated profile' do
            subject { user.reload }

            it { expect(subject.email).to eq new_email }
          end
        end
      end

      context 'no password provided' do
        before do
          click_on 'Update account'
        end

        it { expect(page).to have_inline_error("we need your current password to confirm your changes").for_field('Current password') }
      end
    end
  end

  context 'unsigned in user' do
    before { visit root_path }

    it { expect(page).to have_no_link 'Edit Profile' }
  end
end
