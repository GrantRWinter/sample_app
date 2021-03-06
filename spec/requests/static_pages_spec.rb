require 'spec_helper'

describe "Static Pages" do

  let(:base_title) { "Ruby on Rails Tutorial Sample App" }

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home Page" do
    before(:each) {visit root_path}

    let(:heading)  { 'Sample App' }
    let(:page_title) { ''}
    
    it_should_behave_like 'all static pages'
    it { should_not have_title('| Home') }

    describe "for signed_in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "microposts count language" do
        before { click_link "delete", match: :first }
        it "should be singular when count eq to 1" do
          expect(page).to have_selector("span", text: "1 micropost")
        end
      end
    end
  end

  describe "Help Page" do
    before { visit help_path}

    let(:heading)    { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before(:each) { visit about_path}

    let(:heading)    { 'About' }
    let(:page_title) { 'About' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }

    let(:heading)    { 'Contact' }
    let(:page_title) { 'Contact' }
    
    
    it_should_behave_like "all static pages"
  end

  describe "micropost pagination" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      31.times { FactoryGirl.create(:micropost, user: user) }
      sign_in user
      visit root_path
    end
    after { user.microposts.destroy_all }
    it { should have_selector("div.pagination") }
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title(full_title('About Us'))
    click_link "Help"
    expect(page).to have_title(full_title( 'Help'))
    click_link "Contact"
    expect(page).to have_title(full_title( 'Contact'))
    click_link "Home"
    expect(page).to have_title(full_title(''))
    click_link "sample app"
    expect(page).to have_title(full_title(''))
  end

end
