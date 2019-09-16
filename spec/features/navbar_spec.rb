# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Navbar', type: :feature do
  before do
    @user = create(:user)
  end

  scenario 'displays links for users not signed in' do
    visit root_path
    expect(page).to have_link('Travelers Network')
    expect(page).not_to have_link('Logout')
  end

  scenario 'displays links for signed-in users' do
    login_as(@user)
    visit root_path
    expect(page).to have_link('Travelers Network')
    expect(page).to have_link(@user.name)
    expect(page).to have_link('Find friends')
    expect(page).to have_link('Notifications (0)')
    expect(page).to have_link('Logout')
  end
end
