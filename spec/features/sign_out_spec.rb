require 'rails_helper'

describe 'sign out proccess' do
  let(:user) { create :user }

  subject{ page }

  before :each do
    sign_in user
    click_on user.to_s
    click_on 'Sign out'
  end

  it 'signs out me', js: true do
    is_expected.to have_content('Sign in')
  end
end
