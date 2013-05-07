class ListController < ApplicationController

  # 一覧表示
  def index
    @list = Item.all
  end
  
  # キーワード検索
  def search
    # キーワード
    session[:keyWord] = params[:keyWord]
    
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
  
  # 保存
  def save
    # 悲観的ロックを使用
    
    # DBから該当レコード取得
    @item = Item.find(params[:itemid], :lock => true)
    # 項目の登録
    @item.name=params[:item]
    # 登録者の登録
    @item.update_user=params[:update_user]

    # ケースの登録
    # 手順の登録
    # 参照情報の登録
    @caseids = params[:caseid]
    @casenames = params[:casename]
    @procedurenames = params[:procedurename]
    @references = params[:reference]
    
    @procedures = []
    @cases = Case.find(:all, :conditions => ["item_id = ?", @item.id], :lock => true)
    @cases.each do |a_case|
       idx = 0
       @caseids.each do |caseid|
	       if (a_case.id.to_s == caseid) then
		       a_case.name=@casenames[idx]
		       procedure = Procedure.find(:first, :conditions => ["case_id = ?", a_case.id], :lock => true)
		       procedure.name=@procedurenames[idx]
		       procedure.reference=@references[idx]
		       @procedures.push procedure
	       end
	       idx = idx + 1
       end
    end
    
    # 同一トランザクション内で処理
    ActiveRecord::Base.transaction do
       @item.save!
       @cases.each do |a_case|
           a_case.save!
       end
       @procedures.each do |a_proc|
           a_proc.save!
       end
    end

    render :action => 'edit'
  end

end
