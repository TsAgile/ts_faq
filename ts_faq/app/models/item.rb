class Item < ActiveRecord::Base
  attr_accessible :id, :name, :update_user, :updated_at
  has_many :cases, :dependent => :destroy
end
