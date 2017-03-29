class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.string :name
      t.text :description
    end

    change_table :images do |t|
      t.references :trip
    end
  end
end
