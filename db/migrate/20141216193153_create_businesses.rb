class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :name
      t.string :website
      t.string :phone_number
			t.string :rating
      t.integer :price
      t.string :street_address
      t.string :city
      t.string :state
			t.string :country
			t.string :postal_code
      t.string :zipcode
      t.float :latitude
      t.float :longitude
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
