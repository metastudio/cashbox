require 'spec_helper'

describe 'Organizations list' do
  include MoneyRails::ActionViewExtension

  let(:user) { create :user, :with_organizations }

  before do
    sign_in user
    visit organizations_path
  end

  subject { page }

  it "shows table" do
    organizations.each do |org|
      expect(page).to have_selector('td', text: org.name )
      expect(page).to have_selector('td', text: org.owners )
    end
  end

end
