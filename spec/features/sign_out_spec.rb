require 'spec_helper'

describe 'sign out proccess' do
  let(:user) { create :user }

  subject{ page }

  before :each do
    sign_in user
    click_on("Sign out")
  end

  it "signs out me", js: true do
    expect(subject).to have_content("Sign in")
  end
end
