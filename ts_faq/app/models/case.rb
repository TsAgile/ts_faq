class Case < ActiveRecord::Base
  attr_accessible :item_id, :name, :update_user
  belongs_to :item
  has_many :procedures, :dependent => :destroy
end
