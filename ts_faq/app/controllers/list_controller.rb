class ListController < ApplicationController
  def index
  	@list = Item.all
  end
end
