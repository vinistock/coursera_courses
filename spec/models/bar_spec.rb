describe Bar, type: :model, orm: :mongoid do
  context 'created Bar let' do
    let(:bar) { create(:bar, name: 'test') }

    it { expect(bar).to be_persisted }
    it { expect(bar.name).to eq('test') }
    it { expect(Bar.find(bar.id)).to_not be_nil }
  end

  context Bar do
    it { is_expected.to have_field(:name).of_type(String).with_default_value_of(nil) }
  end
end
