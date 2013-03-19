class Item < ActiveRecord::Base
  attr_accessible :id, :name, :update_user
  has_many :cases, :dependent => :destroy
end
