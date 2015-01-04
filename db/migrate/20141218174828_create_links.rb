class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :biz_link
      t.references :business, index: true
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
