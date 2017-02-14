describe 'Bars API', type: :request do
  context 'caller requests a list of Foos' do
    it_behaves_like 'resource index', :bar do
      let(:response_check) do
        expect(payload.map { |x| x['name'] }).to eq(resources.map(&:name))
        expect(payload.count).to eq(5)
      end
    end
  end

  context 'a specific Bar exists' do
    it_behaves_like 'resource show', :bar do
      let(:response_check) do
        expect(payload).to have_key('id')
        expect(payload).to have_key('name')
        expect(payload['id']).to eq(resource.id.to_s)
        expect(payload['name']).to eq(resource.name)
      end
    end
  end

  context 'create a new Bar' do
    it_behaves_like 'resource create', :bar
  end

  context 'existing Bar' do
    it_behaves_like 'resource update and delete', :bar
  end
end
