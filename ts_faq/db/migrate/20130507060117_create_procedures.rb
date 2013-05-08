class CreateProcedures < ActiveRecord::Migration
  def change
    create_table :procedures do |t|
      t.integer :case_id
      t.string :name
      t.string :reference

      t.timestamps
    end
  end
end
