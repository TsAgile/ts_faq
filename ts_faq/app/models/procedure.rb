class Procedure < ActiveRecord::Base
  attr_accessible :case_id, :procedure, :update_user, :reference
  belongs_to :case
end
