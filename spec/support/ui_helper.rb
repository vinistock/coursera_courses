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

  def login credentials
    fillin_login credentials
    within("#login-form") do
      click_button("Login")
    end

    using_wait_time 5 do
      expect(page).to have_no_css("#login-form")
    end
    expect(page).to have_css("#logout-form", :visible=>false)
    expect(page).to have_css("#navbar-loginlabel",:text=>/#{credentials[:name]}/)
    credentials
  end

  def logged_in?(account=nil)
    account ?
        page.has_css?("#navbar-loginlabel",:text=>/#{account[:name]}/) :
        page.has_css?("#user_id",:text=>/.+/, :visible=>false)
  end

  def fillin_login credentials
    visit root_path unless page.has_css?("#navbar-loginlabel")
    find("#navbar-loginlabel",:text=>"Login").click
    within("#login-form") do
      fill_in("login_email", :with=>credentials[:email])
      fill_in("login_password", :with=>credentials[:password])
    end
  end

  def logout
    if logged_in?
      find("#navbar-loginlabel").click unless page.has_button?("Logout")
      find_button("Logout",:wait=>5).click
      expect(page).to have_no_css("#user_id",:visible=>false,:wait=>5)
    end
  end
end
