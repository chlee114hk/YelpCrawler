class CreateBusinessesCategories < ActiveRecord::Migration
  def change
    create_table :businesses_categories do |t|
      t.references :category, index: true
      t.references :business, index: true

      t.timestamps
    end

    add_index :businesses_categories, [:category_id, :business_id], :unique => true
  end
end
