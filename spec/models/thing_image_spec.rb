describe ThingImage, type: :model do
  context 'valid thing' do
    let(:thing) { build(:thing) }

    it 'build image for thing and save' do
      ti = build(:thing_image, thing: thing)
      ti.save!
      expect(thing).to be_persisted
      expect(ti).to be_persisted
      expect(ti.image).to_not be_nil
      expect(ti.image).to be_persisted
    end

    it 'relate multiple images' do
      thing.thing_images << build_list(:thing_image, 3, thing: thing)
      thing.save!

      expect(Thing.find(thing.id).thing_images.size).to eq(3)

      thing.thing_images.each do |ti|
        expect(ti.image.things.first).to eql(thing)
      end
    end

    it 'build images using factory' do
      thing = create(:thing, :with_image, image_count: 2)
      expect(Thing.find(thing.id).thing_images.size).to eq(2)

      thing.thing_images.each do |ti|
        expect(ti.image.things.first).to eql(thing)
      end
    end
  end

  context 'related thing and image' do
    let(:thing) { create(:thing, :with_image) }
    let(:thing_image) { thing.thing_images.first }

    before do
      expect(ThingImage.where(id: thing_image.id).exists?).to be_truthy
      expect(Image.where(id: thing_image.image_id).exists?).to be_truthy
      expect(Thing.where(id: thing_image.thing_id).exists?).to be_truthy
    end

    after do
      expect(ThingImage.where(id: thing_image.id).exists?).to be_falsey
    end

    it 'deletes link but not image when thing removed' do
      thing.destroy
      expect(Image.where(id: thing_image.image_id).exists?).to be_truthy
      expect(Thing.where(id: thing_image.thing_id).exists?).to be_falsey
    end

    it 'deletes link but not thing when image removed' do
      thing_image.image.destroy
      expect(Image.where(id: thing_image.image_id).exists?).to be_falsey
      expect(Thing.where(id: thing_image.thing_id).exists?).to be_truthy
    end
  end
end
