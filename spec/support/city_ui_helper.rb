module CityUiHelper
  FORM_XPATH = "//h2[text()='City List']/../form"
  LIST_XPATH = "//h2[text()='City List']/../ul"

  def create_city(state)
    visit root_path unless page.has_css?('h2', text: 'City List')

    within(:xpath, FORM_XPATH) do
      fill_in('name', with: state[:name])
      click_button('Create City')
    end

    within(:xpath, LIST_XPATH) do
      expect(page).to have_css('li a', text: state[:name])
    end
  end

  def update_city(current_name, new_name)
    within(:xpath, LIST_XPATH) do
      find(:xpath, "//a[text()='#{current_name}']").click
      find(:xpath, "//input[@ng-model='citiesCtrl.city.name']").set(new_name)
      find(:xpath, "//button[@ng-click='citiesCtrl.update()']").click
    end
  end

  def delete_city(name)
    within(:xpath, LIST_XPATH) do
      find(:xpath, "//a[text()='#{name}']").click
      find(:xpath, "//button[@ng-click='citiesCtrl.remove()']").click
    end
  end
end
