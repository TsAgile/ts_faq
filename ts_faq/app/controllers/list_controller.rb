# -*- coding: utf-8 -*-

require 'kconv'

class ListController < ApplicationController

  # 一覧表示
  def index
    reset_session     #セッションをリセット
    @list = Item.all  # 全件取得
  end
  
  # キーワード検索
  def search
  
    # キーワードをセッションに保存
    if(params[:keyWords] == nil) then
      if(session[:keyWords] == nil) then session[:keyWords] = "" end
    else
      session[:keyWords] = params[:keyWords]
    end
    
    # and/or条件をセッションに保存
    if(params[:condition] == nil) then
      if(session[:condition] == nil) then session[:condition] = "and" end
    else
      session[:condition] = params[:condition]
    end
    
    # 検索結果のリスト
    @list = Array.new
    
    # キーワードごとに検索
    keyWords = session[:keyWords].gsub(/　/," ").split
    if(keyWords.size == 0) then keyWords.push "" end
    
    idx = 0
    keyWords.each do |keyWord|
      # 項目の検索
      wk_list = Item.find(:all, :conditions => ["name LIKE ?", "%" + keyWord + "%"])
      
      # ケースの検索
      cases = Case.find(:all, :conditions => ["name LIKE ?", "%" + keyWord + "%"])
      cases.each do |a_case|
        if !(wk_list.include?(a_case.item)) then wk_list.push a_case.item end
      end

      # 手順の検索
      procedures = Procedure.find(:all, :conditions => ["name LIKE ?", "%" + keyWord + "%"])
      procedures.each do |procedure|
        if !(wk_list.include?(procedure.case.item)) then wk_list.push procedure.case.item end
      end

      # 検索結果のマージ
      if(idx == 0) then
        @list = @list + wk_list
      else
        if(session[:condition] == "and") then
          @list = @list & wk_list
        else
          @list = @list | wk_list
        end
      end
      
      idx = idx + 1
    end

    # ソート
    @list.sort!{|a, b| a.id <=> b.id}
    
    # 検索結果が0件の場合
    if(@list.size) == 0 then
      # メッセージ表示
      flash.now[:info] = NOTICE_NOT_FOUND
    end

    # 一覧画面表示
    render :action => 'index'
  end
  
  # 追加
  def add
    @item = Item.new()
    @item.cases.build
    @item.cases[0].procedures.build

    # 編集画面表示
    render :action => 'edit'
  end

  # 編集
  def edit
    if Item.exists?(:id => params[:id]) then
      # データ取得
      @item = Item.find(params[:id])
      # 編集画面表示
      render :action => 'edit'
    else
      # 存在しない場合、エラーメッセージ
      flash.now[:danger] = ALERT_ALREADY_DELETED 
      # 再検索
      search
    end
  end

  
  # 削除
  def delete
    if Item.exists?(:id => params[:id]) then
      @item = Item.find(params[:id])
      @item.destroy
      flash.now[:success] = NOTICE_DELETE_COMPLETED
    else
      # 存在しない場合、エラーメッセージ
      flash.now[:danger] = ALERT_ALREADY_DELETED
    end
    
    # 検索処理
    search
  end
  
  # 保存（delete-insert方式で追加・更新を一括反映）
  def save
    # 同一トランザクション内で処理
    ActiveRecord::Base.transaction do
    
      # IDがセットされている場合（＝既存データの編集時）
      if (params[:itemid] != "") then

        # IDが既に削除されている場合
        unless Item.exists?(:id => params[:itemid]) then
          # エラーメッセージ
          flash.now[:danger] = ALERT_ALREADY_DELETED
          # 再検索
          search
          return
        end
        
        # データ取得
        @item = Item.find(params[:itemid])
        
        # 排他チェック
        if (params[:updated_at] != @item.updated_at.to_s) then
          @item.errors.add(ALERT_CANCEL, '')
          # 編集画面表示
          render :action => 'edit'
          return
        end
        
        # 既存データ削除
        @item.destroy
        
      end
      
      # 項目を登録
      @item = Item.new(:id => params[:itemid], :name => params[:item], :update_user => params[:update_user])
      @item.save!
      
      # ケースと手順を登録
      caseids = params[:caseid]
      casenames = params[:casename]
      procedurenames = params[:procedurename]
      references = params[:reference]

      idx = 0
      caseids.each do |caseid|
        a_case = @item.cases.build
        a_case.name = casenames[idx]
        a_case.save!

        procedure = a_case.procedures.build
        procedure.name = procedurenames[idx]
        procedure.reference = references[idx]
        procedure.save!
        
        idx = idx + 1
      end
    end
    
    # 処理完了メッセージ
    flash.now[:success] = NOTICE_SAVE_COMPLETED
    
    # 編集画面表示
    render :action => 'edit'
  end
  
  # エクスポート
  def export
    
    # 指定されたテーブルに応じてエクスポート処理
    case params[:table]
    # 「項目」の場合
    when "items" then
      items = Item.all
      data = CSV.generate do |csv|
        csv << ["id", "name", "update_user"]
        items.each do |item|
          csv << [item.id, item.name, item.update_user]
        end
      end
      #data = data.encode(Encoding::SJIS)
      send_data(data, type: 'text/csv', filename: "items_#{Time.now.strftime('%Y_%m_%d_%H_%M_%S')}.csv")
    
    # 「ケース」の場合
    when "cases" then
      cases = Case.all
      data = CSV.generate do |csv|
        csv << ["id", "item_id", "name"]
        cases.each do |a_case|
          csv << [a_case.id, a_case.item_id, a_case.name]
        end
      end
      #data = data.encode(Encoding::SJIS)
      send_data(data, type: 'text/csv', filename: "cases_#{Time.now.strftime('%Y_%m_%d_%H_%M_%S')}.csv")
    
    # 「手順」の場合
    when "procedures" then
      procedures = Procedure.all
      data = CSV.generate do |csv|
        csv << ["id", "case_id", "name", "reference"]
        procedures.each do |procedure|
          csv << [procedure.id, procedure.case_id, procedure.name, procedure.reference]
        end
      end
      #data = data.encode(Encoding::SJIS)
      send_data(data, type: 'text/csv', filename: "procedures_#{Time.now.strftime('%Y_%m_%d_%H_%M_%S')}.csv")
    end
    
  end
  
  # インポート
  def import

    # 同一トランザクション内で処理
    ActiveRecord::Base.transaction do
      
      # 全件削除
      Item.destroy_all
      Case.destroy_all
      Procedure.destroy_all
      
      # 「項目」テーブル
      reader = Kconv.toutf8(params[:item_file].read)
      CSV.parse(reader, headers: true) do |row|
        Item.create! row.to_hash
      end
      
      # 「ケース」テーブル
      reader = Kconv.toutf8(params[:case_file].read)
      CSV.parse(reader, headers: true) do |row|
        Case.create! row.to_hash
      end
      
      # 「手順」テーブル
      reader = Kconv.toutf8(params[:procedure_file].read)
      CSV.parse(reader, headers: true) do |row|
        Procedure.create! row.to_hash
      end
      
      # 処理完了メッセージ
      flash.now[:success] = NOTICE_IMPORT_COMPLETED
      
      # 管理者画面表示
      render :action => 'admin'
    end
  end
  
  # ヘルプ
  def help
    @list = Array.new
    @list.push Item.find(1)
    # ヘルプ画面表示
    render :action => 'help'
  end
end
