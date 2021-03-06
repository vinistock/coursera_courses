describe 'ThingImages', type: :request do
  let(:account) { signup attributes_for(:user) }
  let!(:user) { login account }

  describe 'manage thing/image relationships' do
    context 'valid thing and image' do
      let(:thing) { create_resource(things_path, :thing) }
      let(:image) { create_resource(images_path, :image) }
      let(:thing_image_props) { attributes_for(:thing_image, image_id: image['id']) }

      it 'can associate image with thing' do
        jpost thing_thing_images_path(thing['id']), thing_image_props
        expect(response).to have_http_status(:no_content)

        jget thing_thing_images_path(thing['id'])
        expect(response).to have_http_status(:ok)

        payload = parsed_body
        expect(payload.size).to eq(1)
        expect(payload.first).to include('image_id' => image['id'])
        expect(payload.first).to include('image_caption' => image['caption'])
      end

      it 'must have image' do
        jpost thing_thing_images_path(thing['id']), thing_image_props.except(:image_id)
        expect(response).to have_http_status(:bad_request)

        payload = parsed_body
        expect(payload).to include('errors')
        expect(payload['errors']['full_messages']).to include(/param/, /missing/)
      end
    end
  end

  shared_examples 'can get links' do
    it 'can get links for Thing' do
      jget thing_thing_images_path(thing['id'])
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(images.count)
      expect(parsed_body.first).to include('image_caption')
      expect(parsed_body.first).to_not include('thing_name')
    end

    it 'can get links for Image' do
      jget image_thing_images_path(images.first['id'])
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first).to_not include('image_caption')
      expect(parsed_body.first).to include('thing_name' => thing['name'])
    end
  end

  shared_examples 'get linkables' do |count|
    it 'return linkable things' do
      jget image_linkable_things_path(images.first['id'])
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(count)

      if count > 0
        parsed_body.each do |thing|
          expect(thing['id']).to be_in(unlinked_things.map { |t| t['id'] })
          expect(thing).to include('description')
          expect(thing).to include('notes')
        end
      end
    end
  end

  shared_examples 'can create link' do
    it 'link from Thing to Image' do
      jpost thing_thing_images_path(thing['id']), thing_image_props
      expect(response).to have_http_status(:no_content)

      jget thing_thing_images_path(thing['id'])
      expect(parsed_body.size).to eq(images.count + 1)
    end

    it 'link from Image to Thing' do
      jpost image_thing_images_path(thing_image_props[:image_id]), thing_image_props.merge(thing_id: thing['id'])
      expect(response).to have_http_status(:no_content)

      jget thing_thing_images_path(thing['id'])
      expect(parsed_body.size).to eq(images.count + 1)
    end
  end

  shared_examples 'can update link' do
    it do
      jput thing_thing_image_path(thing_image['thing_id'], thing_image['id']), thing_image.merge('priority' => 0)
      expect(response).to have_http_status(:no_content)
    end
  end

  shared_examples 'can delete link' do
    it do
      jdelete thing_thing_image_path(thing_image['thing_id'], thing_image['id'])
      expect(response).to have_http_status(:no_content)
    end
  end

  shared_examples 'cannot create link' do |status|
    it do
      jpost thing_thing_images_path(thing['id']), thing_image_props
      expect(response).to have_http_status(status)
    end
  end

  shared_examples 'cannot update link' do |status|
    it do
      jput thing_thing_image_path(thing_image['thing_id'], thing_image['id'], thing_image.merge('priority' => 0))
      expect(response).to have_http_status(status)
    end
  end

  shared_examples 'cannot delete link' do |status|
    it do
      jdelete thing_thing_image_path(thing_image['thing_id'], thing_image['id'])
      expect(response).to have_http_status(status)
    end
  end

  describe 'ThingImage Authn policies' do
    let(:thing) { create_resource(things_path, :thing) }
    let(:thing_image) do
      jget thing_thing_images_path(thing['id'])
      expect(response).to have_http_status(:ok)
      parsed_body.first
    end
    let(:images) { (1..3).map { create_resource(images_path, :image) } }
    let!(:unlinked_things) { (1..2).map { create_resource(things_path, :thing) } }
    let(:orphan_image) { create(:image) }
    let(:thing_image_props) { { image_id: orphan_image.id } }

    before do
      images.map do |image|
        jpost thing_thing_images_path(thing['id']), { image_id: image['id'] }
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'anonymous user' do
      before { logout(account) }
      it_behaves_like 'can get links'
      it_behaves_like 'get linkables', 2
      it_behaves_like 'cannot create link', :unauthorized
      it_behaves_like 'cannot update link', :unauthorized
      it_behaves_like 'cannot delete link', :unauthorized
    end

    context 'authenticated user' do
      it_behaves_like 'can get links'
      it_behaves_like 'get linkables', 2
      it_behaves_like 'can create link'
      it_behaves_like 'can update link'
      it_behaves_like 'can delete link'
    end
  end
end
