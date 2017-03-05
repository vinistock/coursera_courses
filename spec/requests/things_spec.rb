describe 'Things', type: :request do
  let(:account) { signup FactoryGirl.attributes_for(:user) }

  context 'quick API check' do
    let!(:user) { login account }

    it_behaves_like 'resource index', :thing
    it_behaves_like 'resource show', :thing
    it_behaves_like 'resource create', :thing
    it_behaves_like 'resource update and delete', :thing do
      let(:new_state) { { name: new_name } }
    end
  end

  shared_examples 'cannot create' do
    it 'create fails' do
      jpost things_path, thing_props
      expect(response.status).to be >= 400
      expect(response.status).to be < 500
      expect(parsed_body).to include('errors')
    end
  end

  shared_examples 'can create' do
    it 'can create' do
      jpost things_path, thing_props
      expect(response).to have_http_status(:created)

      payload = parsed_body
      expect(payload).to include('id')
      expect(payload).to include('name' => thing.name)
      expect(payload).to include('description')
      expect(payload).to include('notes')
    end
    it 'reports error for invalid data' do
      jpost things_path, thing_props.except(:name)
      #pp parsed_body
      #must require :name property -- otherwise get :unprocessable_entity
      #must rescue ActionController::ParameterMissing exception
      #must render :bad_request
      expect(response).to have_http_status(:bad_request)
    end
  end

  shared_examples 'field(s) not redacted' do
    it 'list does include notes' do
      jget things_path
      expect(response).to have_http_status(:ok)

      payload = parsed_body
      expect(payload.size).to_not eq(0)
      payload.each do |r|
        expect(r).to include('id')
        expect(r).to include('name')
        expect(r).to include('description')
        expect(r).to include('notes')
      end
    end

    it 'get does include notes' do
      jget thing_path(thing)
      expect(response).to have_http_status(:ok)

      payload = parsed_body
      expect(payload).to include('id' => thing.id)
      expect(payload).to include('name' => thing.name)
      expect(payload).to include('description')
      expect(payload).to include('notes')
    end
  end

  describe 'access' do
    let(:things_props) { (1..3).map { attributes_for(:thing) } }
    let(:thing_props) { things_props.first }
    let(:things) { Thing.create(things_props) }
    let(:thing) { things[0] }

    context 'anonymous caller' do
      before(:each) { logout(account, nil) }
      it_should_behave_like 'cannot create'
      shared_examples 'field(s) not redacted'
    end
    context 'authenticated caller' do
      let!(:user) { login account }
      it_should_behave_like 'can create'
      shared_examples 'field(s) not redacted'
    end
  end
end