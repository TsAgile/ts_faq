class RenameUserToItems < ActiveRecord::Migration
  def up
    rename_column :items, :user, :update_user
  end

  def down
    rename_column :items, :update_user, :update_user
  end
end
