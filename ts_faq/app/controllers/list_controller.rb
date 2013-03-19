class ListController < ApplicationController

  # 一覧表示
  def index
    @list = Item.all
  end
  
  # キーワード検索
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
  
  # 追加
  def add
    @item = Item.new()
    @item.cases.build
    @item.cases[0].procedures.build
    render :action => 'edit'
  end

  # 編集
  def edit
    @item = Item.find(params[:id])
    render :action => 'edit'
  end

end
