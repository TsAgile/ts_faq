class AddDetailsToProcedures < ActiveRecord::Migration
  def change
    add_column :procedures, :lock_version, :integer, :default => 0
  end
end