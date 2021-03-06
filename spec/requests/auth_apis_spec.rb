describe 'Authentication Api', type: :request do
  let(:user_props) { attributes_for(:user) }

  context 'sign-up' do
    context 'valid registration' do
      it 'successfully creates account' do
        signup(user_props)

        payload = parsed_body
        expect(payload).to include('status' => 'success')
        expect(payload).to include('data')
        expect(payload['data']).to include('id')
        expect(payload['data']).to include('provider' => 'email')
        expect(payload['data']).to include('uid' => user_props[:email])
        expect(payload['data']).to include('name' => user_props[:name])
        expect(payload['data']).to include('email' => user_props[:email])
        expect(payload['data']).to include('created_at', 'updated_at')
      end
    end

    context 'invalid registration' do
      context 'missing information' do
        it 'reports error with messages' do
          signup(user_props.except(:email), :unprocessable_entity)

          payload = parsed_body
          expect(payload).to include('status' => 'error')
          expect(payload).to include('data')
          expect(payload['data']).to include('email' => nil)
          expect(payload).to include('errors')
          expect(payload['errors']).to include('email')
          expect(payload['errors']).to include('full_messages')
          expect(payload['errors']['full_messages']).to include(/Email/i)
        end
      end

      context 'non-unique information' do
        it 'reports non-unique e-mail' do
          signup(user_props)
          signup(user_props, :unprocessable_entity)

          payload = parsed_body
          expect(payload).to include('status' => 'error')
          expect(payload).to include('data')
          expect(payload).to include('errors')
          expect(payload['errors']).to include('email')
          expect(payload['errors']).to include('full_messages')
          expect(payload['errors']['full_messages']).to include(/Email has already been taken/i)
        end
      end
    end
  end

  context 'anonymous user' do
    it 'access unprotected' do
      jget authn_whoami_path
      expect(response).to have_http_status(:ok)
      expect(parsed_body).to eq({})
    end

    it 'fails to access protected resource' do
      jget authn_checkme_path
      expect(response).to have_http_status(:unauthorized)
      expect(parsed_body).to include('errors' => ['Authorized users only.'])
    end
  end

  context 'login' do
    context 'valid user login' do
      let(:account) { signup(user_props, :ok) }
      let!(:user) { login(account) }

      it 'generates access token' do
        expect(response.headers).to include('uid' => account[:uid])
        expect(response.headers).to include('access-token')
        expect(response.headers).to include('client')
        expect(response.headers).to include('token-type' => 'Bearer')
      end

      it 'extracts access headers' do
        expect(access_tokens?).to be_truthy

        expect(response.headers).to include('uid' => account[:uid])
        expect(response.headers).to include('access-token')
        expect(response.headers).to include('client')
        expect(response.headers).to include('token-type' => 'Bearer')
      end

      it 'grants access to resource' do
        jget authn_checkme_path
        expect(response).to have_http_status(:ok)

        payload = parsed_body
        expect(payload).to include('id' => account[:id])
        expect(payload).to include('uid' => account[:uid])
      end

      it 'grants access to resource multiple times' do
        (1..10).each do |idx|
          jget authn_checkme_path
          expect(response).to have_http_status(:ok)
        end
      end

      it 'logout' do
        logout(account, :ok)
        expect(access_tokens?).to be_falsey

        jget authn_checkme_path
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'invalid password' do
      it 'rejects credentials' do
        login({ email: user_props[:email], password: 'wrong-pass' }, :unauthorized)
      end
    end
  end
end
