class Procedure < ActiveRecord::Base
  attr_accessible :case_id, :name, :reference
  belongs_to :case
end
