class CreateCases < ActiveRecord::Migration
  def change
    create_table :cases do |t|
      t.integer :item_id
      t.string :name

      t.timestamps
    end
  end
end
