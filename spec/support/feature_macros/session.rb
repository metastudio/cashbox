module FeatureMacros
  module Session
    def sign_in(user)
      visit new_user_session_path
      within('#new_user') do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Sign in'
      end
      expect(page).to have_content("Signed in successfully")
    end

    def sign_out
      visit root_path
      click_link "Sign out"
    end
  end
end

RSpec.configure do |config|
  config.include FeatureMacros::Session, type: :feature
end
