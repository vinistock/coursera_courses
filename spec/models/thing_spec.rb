describe Thing, type: :model do
  context 'valid thing' do
    let(:thing) { create(:thing) }

    it 'creates new instance' do
      db_thing = Thing.find(thing.id)
      expect(db_thing.name).to eq(thing.name)
    end
  end

  context 'invalid thing' do
    let(:thing) { build(:thing, name: nil) }

    it 'provides error messages' do
      expect(thing.validate).to be_falsey
      expect(thing.errors.messages).to include(:name=>["can't be blank"])
    end
  end
end
