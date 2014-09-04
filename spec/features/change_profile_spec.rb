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

    subject { page }

    it { expect(subject).to have_css('a', text: 'Profile') }

    context 'profile editing' do

      before do
        click_on 'Profile'
        fill_in 'Email', with: email
        fill_in 'Full name', with: full_name
        fill_in 'Phone number', with: phone_number
        fill_in 'Password', with: password
        fill_in 'Password confirmation', with: password_confirmation
        fill_in 'Current password', with: current_password
        click_on 'Update'
      end

      context 'with valid params' do
        it { expect(subject).to have_content 'You updated your account successfully.' }
      end
    end
  end

  context 'unsigned in user' do
    before { visit root_path }

    it { expect(page).to have_no_content 'Profile' }
  end
end
