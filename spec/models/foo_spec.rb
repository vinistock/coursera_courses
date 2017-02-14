describe Foo, type: :model, orm: :active_record do
  context 'created Foo let' do
    let(:foo) { create(:foo, name: 'test') }

    it { expect(foo).to be_persisted }
    it { expect(foo.name).to eq('test') }
    it { expect(Foo.find(foo.id)).to_not be_nil }
  end
end
