module ApiHelper
  def parsed_body
    JSON.parse(response.body)
  end

  %w(post put get patch head delete).each do |method_name|
    define_method("j#{method_name}") do |path, params={}, headers={}|

      if %w(post put patch).include?(method_name)
        headers = headers.merge('Content-Type' => 'application/json') unless params.empty?
        params = params.to_json
      end

      self.send(method_name, path, params, headers.merge(access_tokens))
    end
  end

  def signup(registration, status=:ok)
    jpost user_registration_path, registration
    expect(response).to have_http_status(status)
    payload = parsed_body

    if response.ok?
      registration.merge(id: payload['data']['id'], uid: payload['data']['uid'])
    end
  end

  def login(credentials, status=:ok)
    jpost user_session_path, credentials.slice(:email, :password)
    expect(response).to have_http_status(status)
    response.ok? ? parsed_body['data'] : parsed_body
  end

  def logout(credentials, status=:ok)
    jdelete destroy_user_session_path, credentials.slice(:email, :password)
    @last_tokens = {}
    expect(response).to have_http_status(status) if status
  end

  def access_tokens?
    !response.headers['access-token'].nil? if response
  end

  def access_tokens
    if access_tokens?
      @last_tokens = %w(access-token uid client access-token).inject({}) { |h, k| h[k] = response.headers[k]; h }
    end

    @last_tokens || {}
  end

  def create_resource(path, factory, status=:created)
    jpost path, attributes_for(factory)
    expect(response).to have_http_status(status) if status
    parsed_body
  end
end

RSpec.shared_examples 'resource index' do |model|
  context "caller requests a list of #{model}s" do
    let!(:resources) { (1..5).map { |i| create(model) } }
    let(:payload) { parsed_body }

    it 'returns all instances' do
      jget send("#{model}s_path", { param1: 'whatever', 'Accept' => 'application/json' })

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
    jget send("#{model}_path", resource.id)
    expect(response).to have_http_status(:ok)

    response_check if respond_to?(:response_check)
  end

  it 'returns not found when using incorrect ID' do
    jget send("#{model}_path", bad_id)
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
    jput(send("#{model}_path", resource.id), new_state)
    expect(response).to have_http_status(:no_content)

    udpate_check if respond_to?(:update_check)
  end

  it 'can be deleted' do
    jhead send("#{model}_path", resource.id)
    expect(response).to have_http_status(:ok)

    jdelete send("#{model}_path", resource.id)
    expect(response).to have_http_status(:no_content)

    jhead send("#{model}_path", resource.id)
    expect(response).to have_http_status(:not_found)
  end
end
