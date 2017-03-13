xfeature 'Mainpages', type: :feature, js: true do
  context 'when the main page is accessed' do
    before { visit root_path }

    it 'index page has bootstrap styling' do
      expect(page).to have_css('div.container-fluid')
    end

    it 'displays the main application page' do
      expect(page).to have_content('Hello (from spa/pages/main.html)')
    end

    it 'displays the foos tile' do
      expect(page).to have_content('City List')
    end
  end
end
