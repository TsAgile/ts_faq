class Item < ActiveRecord::Base
  attr_accessible :name, :update_user
  has_many :cases, :dependent => :destroy
end
