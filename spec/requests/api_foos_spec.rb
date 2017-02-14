describe 'Foo API', type: :request do
  context 'caller requests a list of Foos' do
    let!(:foos) { (1..5).map { |i| create(:foo) } }

    it 'returns all instances' do
      get foos_path, { param1: 'whatever', 'Accept' => 'application/json' }

      expect(request.method).to eq('GET')
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
      expect(response['X-Frame-Options']).to eq('SAMEORIGIN')

      expect(parsed_body.count).to eq(5)
      expect(parsed_body.map { |x| x['name'] }).to eq(foos.map(&:name))
    end
  end

  context 'a specific Foo exists' do
    let(:foo) { create(:foo) }
    let(:bad_id) { 1234556789 }

    it 'returns Foo when using correct ID' do
      get foo_path(foo.id)
      expect(response).to have_http_status(:ok)

      payload = parsed_body
      expect(payload).to have_key('id')
      expect(payload).to have_key('name')
      expect(payload['id']).to eq(foo.id)
      expect(payload['name']).to eq(foo.name)
    end

    it 'returns not found when using incorrect ID' do
      get foo_path(bad_id)
      expect(response).to have_http_status(:not_found)
      expect(response.content_type).to eq('application/json')

      payload = parsed_body
      expect(payload).to have_key('errors')
      expect(payload['errors']).to have_key('full_messages')
      expect(payload['errors']['full_messages'].first).to include('cannot', "#{bad_id}")
    end
  end

  context 'create a new Foo' do
    let(:foo_state) { attributes_for(:foo) }

    it 'can create with provided name' do
      jpost foos_path, foo_state

      expect(response).to have_http_status(:created)
      expect(response.content_type).to eq('application/json')
    end
  end

  context 'existing Foo' do
    let(:foo) { create(:foo) }
    let(:new_name) { 'testing' }

    it 'can update name' do
      expect(foo.name).to_not eq(new_name)

      jput foo_path(foo.id), { name: new_name }

      expect(response).to have_http_status(:no_content)
      expect(foo.reload.name).to eq(new_name)
    end

    it 'can be deleted' do
      head foo_path(foo.id)
      expect(response).to have_http_status(:ok)

      delete foo_path(foo.id)
      expect(response).to have_http_status(:no_content)

      head foo_path(foo.id)
      expect(response).to have_http_status(:not_found)
    end
  end
end
