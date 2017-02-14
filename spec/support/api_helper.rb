module ApiHelper
  def parsed_body
    JSON.parse(response.body)
  end

  %w(post put).each do |method_name|
    define_method("j#{method_name}") do |path, params={}, headers={}|
      headers = headers.merge('Content-Type' => 'application/json') unless params.empty?
      self.send(method_name, path, params.to_json, headers)
    end
  end
end

RSpec.shared_examples 'resource index' do |model|
  context "caller requests a list of #{model}s" do
    let!(:resources) { (1..5).map { |i| create(model) } }
    let(:payload) { parsed_body }

    it 'returns all instances' do
      get send("#{model}s_path", { param1: 'whatever', 'Accept' => 'application/json' })

      expect(request.method).to eq('GET')
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
      expect(response['X-Frame-Options']).to eq('SAMEORIGIN')
      response_check if respond_to?(:response_check)
    end
  end
end

RSpec.shared_examples 'resource show' do |model|
  let(:resource) { create(model) }
  let(:bad_id) { 1234556789 }
  let(:payload) { parsed_body }

  it "returns #{model} when using correct ID" do
    get send("#{model}_path", resource.id)
    expect(response).to have_http_status(:ok)

    response_check if respond_to?(:response_check)
  end

  it 'returns not found when using incorrect ID' do
    get send("#{model}_path", bad_id)
    expect(response).to have_http_status(:not_found)
    expect(response.content_type).to eq('application/json')

    expect(payload).to have_key('errors')
    expect(payload['errors']).to have_key('full_messages')
    expect(payload['errors']['full_messages'].first).to include('cannot', "#{bad_id}")
  end
end

RSpec.shared_examples 'resource create' do |model|
  let(:resource_state) { attributes_for(model) }

  it 'can create with provided name' do
    jpost(send("#{model}s_path"), resource_state)

    expect(response).to have_http_status(:created)
    expect(response.content_type).to eq('application/json')
  end
end

RSpec.shared_examples 'resource update and delete' do |model|
  let(:resource) { create(model) }
  let(:new_name) { 'testing' }

  it 'can update name' do
    expect(resource.name).to_not eq(new_name)

    jput(send("#{model}_path", resource.id), { name: new_name })

    expect(response).to have_http_status(:no_content)
    expect(resource.reload.name).to eq(new_name)
  end

  it 'can be deleted' do
    head send("#{model}_path", resource.id)
    expect(response).to have_http_status(:ok)

    delete send("#{model}_path", resource.id)
    expect(response).to have_http_status(:no_content)

    head send("#{model}_path", resource.id)
    expect(response).to have_http_status(:not_found)
  end
end
