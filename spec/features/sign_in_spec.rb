require 'rails_helper'

describe 'sign in proccess' do
  let(:email)    { generate :email}
  let(:password) { 'passw0rd' }
  let!(:user)    { create :user, email: email, password: password }

  subject{ page }

  before :each do
    visit root_path
  end

  context "with wrong password" do
    before :each do
      fill_in 'Email', with: email
      fill_in 'Password', with: 'wrongpassword'
      click_button 'Sign in'
    end

    it "doesn't sign in" do
      expect(subject).to have_content("Invalid Email or password")
    end
  end

  context "with wrong email" do
    before :each do
      fill_in 'Email', with: 'wrond@cashbox.dev'
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    it "doesn't sign in" do
      expect(subject).to have_content("Invalid Email or password")
    end
  end

  context "with valid credentials" do
    before :each do
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    it "signs in" do
      expect(subject).to have_flash_message("Signed in successfully")
    end
  end
end
