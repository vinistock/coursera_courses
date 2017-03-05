describe 'Images', type: :request, mongoid: true do
  let(:account) { signup(attributes_for(:user)) }

  context 'quick API check' do
    let!(:user) { login account }

    it_behaves_like 'resource index', :image
    it_behaves_like 'resource show', :image
    it_behaves_like 'resource create', :image
    it_behaves_like 'resource update and delete', :image do
      let(:new_state) { { caption: new_name } }
    end
  end

  shared_examples 'cannot create' do
    it 'create fails' do
      jpost images_path, image_props
      expect(response.status).to be >= 400
      expect(response.status).to be < 500
      expect(parsed_body).to include('errors')
    end
  end

  shared_examples 'can create' do
    it 'can create' do
      jpost images_path, image_props
      expect(response).to have_http_status(:created)
      payload = parsed_body
      expect(payload).to include('id')
      expect(payload).to include('caption' => image_props[:caption])
    end
  end

  shared_examples 'all fields present' do
    it 'list has all fields' do
      jget images_path
      expect(response).to have_http_status(:ok)
      payload = parsed_body
      expect(payload.size).to_not eq(0)
      payload.each do |r|
        expect(r).to include('id')
        expect(r).to include('caption')
      end
    end

    it 'get has all fields' do
      jget image_path(image.id)
      expect(response).to have_http_status(:ok)
      payload = parsed_body
      expect(payload).to include('id' => image.id)
      expect(payload).to include('caption' => image.caption)
    end
  end

  describe 'access' do
    let(:images_props) { (1..3).map { attributes_for(:image, :with_caption) } }
    let(:image_props) { images_props.first }
    let!(:images) { Image.create(images_props) }
    let(:image) { images.first }

    context 'unauthenticated caller' do
      before { logout(account, nil) }

      it_behaves_like 'cannot create'
      it_behaves_like 'all fields present'
    end

    context 'authenticated caller' do
      let!(:user) { login(account) }

      it_behaves_like 'can create'
      it_behaves_like 'all fields present'
    end
  end
end
