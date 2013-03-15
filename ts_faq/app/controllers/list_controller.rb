class ListController < ApplicationController
  def index
    @list = Item.all
  end
  
  def search
    # キーワード
    @keyWord = params[:keyWord]
  
    # 項目の検索
    @list = Item.find(:all, :conditions => ["name LIKE ?", "%" + @keyWord + "%"])
    
    # ケースの検索
    @cases = Case.find(:all, :conditions => ["name LIKE ?", "%" + @keyWord + "%"])
    @cases.each do |a_case|
      if !(@list.include?(a_case.item)) then
        @list.push a_case.item
      end
    end
    
    # 手順の検索
    @procedures = Procedure.find(:all, :conditions => ["name LIKE ?", "%" + @keyWord + "%"])
    @procedures.each do |procedure|
      if !(@list.include?(procedure.case.item)) then
        @list.push procedure.case.item
      end
    end
    
    # ソート
    @list.sort!{|a, b| a.id <=> b.id}
    
    render :action => 'index'
  end
  
end
