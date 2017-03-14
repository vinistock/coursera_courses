module UiHelper
  def fillin_signup(registration)
    visit '/#/signup' unless page.has_css?('#signup-form')
    expect(page).to have_css('#signup-form')
    password_confirmation = registration[:password_confirmation] || registration[:password]

    fill_in('signup-email', with: registration[:email])
    fill_in('signup-name', with: registration[:name])
    fill_in('signup-password', with: registration[:password])
    fill_in('signup-password_confirmation', with: password_confirmation)
  end

  def signup(registration, success=true)
    fillin_signup(registration)
    click_on('Sign Up')

    if success
      expect(page).to have_no_button('Sign Up')
    else
      expect(page).to have_button('Sign Up')
    end
  end

  def login(registration)
    find('#navbar-loginlabel', text: 'Login').click

    within '#login-form' do
      fill_in('login_email', with: registration[:email])
      fill_in('login_password', with: registration[:password])
      click_button('Login')
    end
  end
end
