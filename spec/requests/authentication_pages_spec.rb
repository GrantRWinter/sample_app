require 'spec_helper'

describe "Authentication" do
  
  subject { page }

  describe "signin page" do
    before { visit signin_path }
    it { should have_content('Sign in') }
    it { should have_selector('h1', text: 'Sign in') }
    it { should have_title('Sign in') }

    #exercise 9.6.3
    it { should_not have_content('Profile') }
    it { should_not have_content('Settings') }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-error') }
      it { should have_error_message('Invalid') } #use of a custom matcher found in spec/support/utilities.rb this
      #this is the exact same test as the one immediately above.

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      # before do
      #   fill_in "Email",     with: user.email.upcase
      #   fill_in "Password",  with: user.password
      #   click_button "Sign in"
      # end

      before { sign_in(user) }

      it { should have_title(user.name) }
      it { should have_link('Users',       href: users_path)}
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Settings',    href: edit_user_path(user))}
      it { should have_link('Sign out',    href: signout_path) }
      it { should_not have_link('Sign in', href: signup_path) }
    end
  end

  describe "authorization" do

    describe "for admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
      before { sign_in admin, no_capybara: true }

      describe "should not be able to self delete" do
      #   before { delete user_path(admin)}
      #   it { should_not change(User, :count).by(-1)}
      # end
        specify { expect {delete user_path(admin)}.not_to change(User, :count).by(-1) }
       
      end
    end

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "when attempting to visit a protected page" do
        before do 
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it { should have_title('Edit user') }
          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end

          describe "when signing in again" do
            before do
              click_link "Sign out"
              visit signin_path
              fill_in "Email", with: user.email
              fill_in "Password", with: user.password
              click_button "Sign in"
            end

            it "should render the default (profile) page" do 
              expect(page).to have_title(user.name)
            end
          end
        end
      end

      describe "in the Users controller" do
        
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end
      end

      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user, no_capybara: true }

      describe "submitting a GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end 

    describe "for signed in user" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user, no_capybara: true }

      describe "accessing 'new user page'" do
        before { get new_user_path }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "can not delete other users' microposts"  do
        let(:other_user) { FactoryGirl.create(:user) }
        before { visit user_path(other_user) }
        it { should_not have_link('delete') }
      end
    end
  end
end
