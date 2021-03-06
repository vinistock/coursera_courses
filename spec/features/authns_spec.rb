feature 'Authns', type: :feature, js: true do
  let(:registration) { attributes_for(:user) }

  feature 'sign-up' do
    context 'valid registration' do
      scenario 'creates account and navigfates away from signup page' do
        start_time = Time.now
        signup(registration)
        expect(page).to have_no_css('#signup-form')

        user = User.where(email: registration[:email]).first
        expect(user.created_at).to be > start_time
      end
    end

    context 'rejected registration' do
      before do
        signup registration
        expect(page).to have_no_css('#signup-form')
      end

      scenario 'account not created and stays on page' do
        dup_user = attributes_for(:user, email: registration[:email])
        signup dup_user, false

        expect(User.where(email: registration[:email], name: registration[:name])).to exist
        expect(User.where(email: dup_user[:email], name: dup_user[:name])).to_not exist

        expect(page).to have_css('#signup-form')
        expect(page).to have_button('Sign Up')
      end

      scenario 'displays error messages' do
        bad_props = attributes_for(:user, email: registration[:email], password: '123').merge(password_confirmation: 'abc')
        signup bad_props, false

        expect(page).to have_css('#signup-form > span.invalid', text: "Password confirmation doesn't match Password")
      end
    end

    context 'invalid field' do
      scenario 'bad email' do
        fillin_signup attributes_for(:user, email: 'yadayadayada')
        expect(page).to have_css("input[name='signup-email'].ng-invalid-email")
      end

      scenario 'missing password' do
        fillin_signup attributes_for(:user, password: nil)
        expect(page).to have_css("input[name='signup-password'].ng-invalid-required")
        expect(page).to have_css("input[name='signup-password_confirmation'].ng-invalid-required")
      end
    end
  end

  feature 'anonymous user' do
    scenario 'shown login form' do
      visit root_path
      click_on('Login')
      expect(page).to have_no_css('#logout-form')
      expect(page).to have_css('#login-form')
    end
  end

  feature 'login' do
    before do
      signup(registration)
      login(registration)
    end

    context 'valid user login' do
      scenario 'closes form and displays current user name' do
        using_wait_time 5 do
          expect(page).to have_css('#navbar-loginlabel', text: /#{registration[:name]}/)
          expect(page).to have_no_css('#login-form')
          expect(page).to have_no_css('#logout-form')
        end
      end

      scenario 'menu shows logout option with identity' do
        click_link(registration[:name])

        using_wait_time 5 do
          expect(page).to have_css('#user_id', text: /.+/, visible: false)
          expect(page).to have_css('#logout-identity label', text: registration[:name])

          within '#logout-form' do
            expect(page).to have_button('Logout')
          end
        end
      end

      scenario 'can access authenticated resources' do
        checkme
        within 'div.checkme-user' do
          expect(page).to have_css('label', text: /#{registration[:name]}/)
          expect(page).to have_css('label', text: /#{registration[:email]}/)
        end
      end
    end

    context 'invalid login' do
      before do
        logout
      end

      scenario "error message displayed and leaves user unauthenticated" do
        fillin_login registration.merge(:password=>"badpassword")
        within("#login-form") do
          click_button("Login")
        end

        expect(logged_in?(registration)).to be false
        expect(page).to have_css("#login-form") #form still displayed
        within("div#login-submit") do           #error message in form
          expect(page).to have_css("span.invalid",:text=>/Invalid credentials/)
        end
        expect(page).to have_css("#navbar-loginlabel",:text=>"Login")
      end
    end
  end

  feature 'logout' do
    before do
      signup registration
      login registration
    end

    scenario 'closes form and removes user name' do
      login_criteria = ['#navbar-loginlabel', text: 'Login']
      user_name_criteria = ['#navbar-loginlabel', text: /#{registration[:name]}/]
      user_id_criteria = ['#user_id', visible: false]

      expect(page).to have_no_css(*login_criteria)
      expect(page).to have_css(*user_name_criteria)
      expect(page).to have_css(*user_id_criteria)

      logout

      expect(page).to have_css(*login_criteria)
      expect(page).to have_no_css(*user_name_criteria)
      expect(page).to have_no_css(*user_id_criteria)
    end

    scenario 'can no longer access authenticated resources' do
      logout
      checkme
      within 'div.checkme-user' do
        expect(page).to have_no_css('label', text: /#{registration[:name]}/)
        expect(page).to have_css('label', text: /Authorized users only/)
      end
    end
  end

  def checkme
    visit root_path + '#/authn'
    within 'div#authn-check' do
      click_button('checkMe() says...')
    end
  end
end
