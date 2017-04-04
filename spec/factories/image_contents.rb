FactoryGirl.define do
  factory :image_content do
    content_type 'image/jpg'
    content { File.open("#{ENV['HOME']}/Pictures/tiles.jpg") { |f| Base64.encode64(f.read) } }
  end
end
