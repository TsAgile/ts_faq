class ListController < ApplicationController

  # 一覧表示
  def index
    @list = Item.all
  end
  
  # キーワード検索
  def search
  
    # キーワード
    if(params[:keyWord] == nil) then
      if(session[:keyWord] == nil) then session[:keyWord] = "" end
    else
      session[:keyWord] = params[:keyWord]
    end
    
    # 項目の検索
    @list = Item.find(:all, :conditions => ["name LIKE ?", "%" + session[:keyWord] + "%"])
    
    # ケースの検索
    @cases = Case.find(:all, :conditions => ["name LIKE ?", "%" + session[:keyWord] + "%"])
    @cases.each do |a_case|
      if !(@list.include?(a_case.item)) then
        @list.push a_case.item
      end
    end
    
    # 手順の検索
    @procedures = Procedure.find(:all, :conditions => ["name LIKE ?", "%" + session[:keyWord] + "%"])
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

  
  # 削除
  def delete
    @item = Item.find(params[:id])
    if !(@item.nil?) then
      @item.destroy
    end
    search
  end
  
  # 保存（delete-insert方式）
  def save
  
    # 同一トランザクション内で処理
    ActiveRecord::Base.transaction do
    
      # 既存データがあれば削除
      if (params[:itemid] != "") then
        Item.delete(params[:itemid])
      end
      
      # 項目を登録
      @item = Item.new(:id => params[:itemid], :name => params[:item], :update_user => params[:update_user])
      @item.save!
      
      # ケースと手順を登録
      caseids = params[:caseid]
      casenames = params[:casename]
      procedurenames = params[:procedurename]
      references = params[:reference]

      @item.cases.build
      
      idx = 0
      caseids.each do |caseid|
        a_case = @item.cases[idx]
        a_case.name = casenames[idx]
        a_case.save!

        a_case.procedures.build
        procedure = a_case.procedures[0]
        procedure.name = procedurenames[idx]
        procedure.reference = references[idx]
        procedure.save!
      end
      idx = idx + 1
    end
    render :action => 'edit'
  end
end
