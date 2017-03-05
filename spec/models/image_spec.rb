describe Image, type: :model, mongoid: true do
  context 'build valid image' do
    it 'default image created with random caption' do
      image = create(:image)
      expect(image.creator_id).to_not be_nil
      expect(image.save).to be_truthy
    end

    it 'image with User and non-nil caption' do
      user = create(:user)
      image = create(:image, :with_caption, creator_id: user.id)
      expect(image.caption).to_not be_nil
      expect(image.creator_id).to eq(user.id)
      expect(image.save).to be_truthy
    end

    it 'image with explicit nil caption' do
      image = create(:image, caption: nil)
      expect(image.creator_id).to_not be_nil
      expect(image.caption).to be_nil
      expect(image.save).to be_truthy
    end
  end
end
