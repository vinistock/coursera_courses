class Trip < ActiveRecord::Base
  include Protectable
  validates :name, presence: true
  has_many :images
end
