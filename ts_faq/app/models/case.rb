class Case < ActiveRecord::Base
  attr_accessible :id, :item_id, :name
  belongs_to :item
  has_many :procedures, :dependent => :destroy
end
