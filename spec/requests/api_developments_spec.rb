require 'rails_helper'

describe 'ApiDevelopments', type: :request do
  def parsed_body
    JSON.parse(response.body)
  end
  
  describe 'RDBMS-backed' do
    before { Foo.delete_all }
    after { Foo.delete_all }
    
    it 'create RDBMS-backed model' do
      object = Foo.create(name: 'test')
      expect(Foo.find(object.id).name).to eq('test')
    end
    
    it 'expose RDBMS-backed API resource' do
      object = Foo.create(name: 'test')
      expect(foos_path).to eq('/api/foos')
      get foo_path(object.id)
      expect(response).to have_http_status(:ok)
      expect(parsed_body['name']).to eq('test')
    end
  end

  describe 'MongoDB-backed' do
    before { Bar.delete_all }
    after { Bar.delete_all }
    
    it 'create MongoDB-backed model' do
      object = Bar.create(name: 'test')
      expect(Bar.find(object.id).name).to eq('test')
    end
    
    it 'expose MongoDB-backed API resource' do
      object = Bar.create(name: 'test')
      expect(bars_path).to eq('/api/bars')
      get bar_path(object.id)
      expect(response).to have_http_status(:ok)
      expect(parsed_body['name']).to eq('test')
      expect(parsed_body).to include('created_at')
      expect(parsed_body).to include('id'=>object.id.to_s)
    end
  end

  describe 'RDBMS-backed' do
    before { City.delete_all }
    after { City.delete_all }

    it 'create RDBMS-backed model' do
      object = City.create(name: 'test')
      expect(City.find(object.id).name).to eq('test')
    end

    it 'expose RDBMS-backed API resource' do
      object = City.create(name: 'test')
      expect(cities_path).to eq('/api/cities')
      get city_path(object.id)
      expect(response).to have_http_status(:ok)
      expect(parsed_body['name']).to eq('test')
    end
  end

  describe 'MongoDB-backed' do
    before { State.delete_all }
    after { State.delete_all }

    it 'create MongoDB-backed model' do
      object = State.create(name: 'test')
      expect(State.find(object.id).name).to eq('test')
    end

    it 'expose MongoDB-backed API resource' do
      object = State.create(name: 'test')
      expect(states_path).to eq('/api/states')
      get state_path(object.id)
      expect(response).to have_http_status(:ok)
      expect(parsed_body['name']).to eq('test')
      expect(parsed_body).to include('created_at')
      expect(parsed_body).to include('id'=>object.id.to_s)
    end
  end
end
