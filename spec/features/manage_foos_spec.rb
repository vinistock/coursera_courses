require 'support/city_ui_helper'

feature 'ManageFoos', type: :feature, js: true do
  include CityUiHelper
  FORM_XPATH = CityUiHelper::FORM_XPATH
  LIST_XPATH = CityUiHelper::LIST_XPATH

  feature 'view existing Foos' do
    let(:cities) { (1..5).map { create(:city) }.sort_by { |v| v['name'] } }

    scenario 'when no instances exist' do
      visit root_path

      within(:xpath, LIST_XPATH) do
        expect(page).to have_no_css('li')
        expect(page).to have_css('li', count: 0)
        expect(all('ul li').size).to eq(0)
      end
    end

    scenario 'when instances exist' do
      visit root_path if cities

      within(:xpath, LIST_XPATH) do
        expect(page).to have_css("li:nth-child(#{cities.count})")
        expect(page).to have_css('li', count: cities.count)
        expect(all('li').size).to eq(cities.count)

        cities.each_with_index do |city, index|
          expect(page).to have_css("li:nth-child(#{index+1})", text: city.name)
        end
      end
    end
  end

  feature 'add new Foo' do
    let(:city_state) { attributes_for(:city) }

    background do
      visit root_path
      expect(page).to have_css('h2', text: 'City List')
      expect(page).to have_css('li', count: 0)
    end

    scenario 'has input form' do
      expect(page).to have_css('label', text: 'Name:')
      expect(page).to have_css("input[name='name'][ng-model='citiesCtrl.city.name']")
      expect(page).to have_css("button[ng-click='citiesCtrl.create()']", text: 'Create City')
    end

    scenario 'complete form' do
      within(:xpath, FORM_XPATH) do
        fill_in('name', with: city_state[:name])
        click_button('Create City')
      end

      within(:xpath, LIST_XPATH) do
        expect(page).to have_css('li', count: 1)
        expect(page).to have_content(city_state[:name])
      end
    end

    scenario 'complete form with XPath' do
      find(:xpath, "//input[@ng-model='citiesCtrl.city.name']").set(city_state[:name])
      find(:xpath, "//button[@ng-click='citiesCtrl.create()']").click

      within(:xpath, LIST_XPATH) do
        expect(page).to have_xpath('//li', count: 1)
        expect(page).to have_content(city_state[:name])
      end
    end

    scenario 'complete with helper' do
      create_city(city_state)

      within(:xpath, LIST_XPATH) do
        expect(page).to have_css('li', count: 1)
      end
    end
  end

  feature 'with existing Foo' do
    let(:city_state) { attributes_for(:city) }

    background do
      create_city(city_state)
    end

    scenario 'can be updated' do
      update_city(city_state[:name], 'Chicago')

      within(:xpath, LIST_XPATH) do
        expect(page).to have_css('li a', text: 'Chicago')
      end
    end

    scenario 'can de deleted' do
      delete_city(city_state[:name])

      within(:xpath, LIST_XPATH) do
        expect(page).to have_no_css('li a', text: city_state[:name])
      end
    end
  end
end
