require 'spec_helper'

describe 'Page' do
  
  
  describe 'authenticated store_admin user' do
    let!(:admin) {Customer.create!(email: 'admin@admin.com', password: 'password', first_name: 'admin', last_name: 'user', admin: true)}
    let!(:user) {Customer.create!(email: 'user@user.com', password: 'password', first_name: 'user', last_name: 'user', admin: false)}
    let!(:store) {Store.create!(name: 'Cool Sunglasses', path: 'cool-sunglasses', description: 'We have cool sunglasses', status: 'active')}

      def login_the_admin
        visit login_path
        fill_in 'email', with: 'admin@admin.com'
        fill_in 'password', with: 'password'
        click_button 'Login'
      end

      it "should be able to create" do
        login_the_admin
        visit new_page_path(store)
        fill_in 'Title', with: 'About'
        fill_in 'Body', with: 'Our store is great, we have the best sunglasses' 
        click_button 'save'
        expect(page).to have_content('Our store is great')
      end

      it "should be able to edit" do 
        login_the_admin
        visit new_page_path(store)
        fill_in 'Title', with: 'About'
        fill_in 'Body', with: 'Our store is great, we have the best sunglasses' 
        click_button 'save'

        expect(current_path).to eq "/cool-sunglasses/pages/1"
        visit "/cool-sunglasses/pages/1/edit"
        fill_in 'Title', with: 'History'
        fill_in 'Body', with: 'Our store is great, we have the best sunglasses' 
        click_button 'update'
        expect(page).to have_content "History"
      end

      it "should be able to delete" do 
        page = Page.create!(title:"About", body:"this is about our store", store_id: store.id)
        login_the_admin
        visit store_admin_path(store)
        within("#store-pages") do 
          click_link 'Delete'
        end

        expect(Page.count).to eq 0
      end

      it "should only edit their own pages" do 
        page = Page.create!(title:"About", body:"this is about our store", store_id: 5)
        login_the_admin
        visit store_admin_path(store)
        within("#store-pages") do 
          expect(page).to_not have_content 'Delete'
        end
      end
  end

  describe 'unauthenticated user' do
    it "should see pages" do 
      store = Store.create!(name: 'Cool Sunglasses', path: 'cool-sunglasses', description: 'We have cool sunglasses', status: 'active')
      about = Page.create!(title:"About", body:"this is about our store", store_id: store.id)
      visit page_path(store,about)
      expect(current_path).to eq page_path(store,about)
      expect(page).to have_content "About"
    end


    it "should not be able to edit" do 
      store = Store.create!(name: 'Cool Sunglasses', path: 'cool-sunglasses', description: 'We have cool sunglasses', status: 'active')
      about = Page.create!(title:"About", body:"this is about our store", store_id: store.id)
      visit edit_page_path(store,about)
      expect(current_path).to eq home_path(store)
    end
  end
  


end
