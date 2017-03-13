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
    scenario 'shown login form'
  end

  feature 'login' do
    context 'valid user login' do
      scenario 'closes form and displays current user name'
      scenario 'menu shows logout option'
      scenario 'can access authenticated resources'
    end

    context 'invalid login' do
      scenario 'error message displayed and leaves user unauthenticated'
    end
  end

  feature 'logout' do
    scenario 'closes form and removes user name'
    scenario 'can no longer access authenticated resources'
  end
end
