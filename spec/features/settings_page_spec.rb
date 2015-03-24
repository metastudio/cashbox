require 'spec_helper'

describe 'Settings' do
  let(:user) { create :user, :with_organization }

  before do
    sign_in user
  end

  subject { page }

  it "root page have settings link" do
    expect(subject).to have_link('Settings')
  end

  context 'on page' do
    before { click_link 'Settings' }

    it { expect(page).to have_link('Organizations')}
    it { expect(page).to have_link('Bank accounts')}
    it { expect(page).to have_link('Categories')}
    it { expect(page).to have_link('Members')}

    it 'Bank accounts is active by def' do
      expect(page).to have_css('.active', text: 'Bank accounts')
    end

    context 'when switch to other setting' do
      before { click_link 'Categories' }
      it 'Categories is active now' do
        expect(page).to have_css('.active', text: 'Categories')
      end
    end
  end
end
