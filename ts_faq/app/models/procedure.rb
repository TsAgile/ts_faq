class Procedure < ActiveRecord::Base
  attr_accessible :id, :case_id, :name, :reference
  belongs_to :case
end
