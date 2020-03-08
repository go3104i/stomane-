class PerformancesController < ApplicationController

  def performances
    @user = User.find_by(user_id: session[:user_id])
    @performances = Performance.find_by(user_id: session[:user_id])
    if @performances != nil
      @performances = Performance.where(user_id: session[:user_id]).order(end_date: "ASC")
    end
    @dividends = Dividend.find_by(user_id: session[:user_id])
    if @dividends != nil
      @dividends = Dividend.where(user_id: session[:user_id]).order(dividend_date: "ASC")
    end
    @total_Valuation_pl = 0
  end

  #liquidationビューの決済ボタンより------------------------------------------------------------------
  def liquidation_update
    #①レンダー処理用値設定
    @tab_select = "02"
    render_pack

    #②「決済単価」か「約定単価」かの判定 「取得単価」の場合はparams[:end_fee]に０を挿入 
    @price_type = params[:price_type]
    price_type_checker2

    #③決済数量ラジオボタンが全決済にチェックの場合、stocksテーブルの保有数量をperformancesテーブルの決済数量に挿入
    @liquidation_type = params[:liquidation_type]
    if @liquidation_type == "01"
      params[:owned_quantity] = @stock.owned_quantity
    end

    #④入力フォームの決済情報データをインスタンス変数に格納
    @performance = Performance.new(      
      owned_quantity: params[:owned_quantity],
      end_date: params[:end_date],
      end_price: params[:end_price],
      end_fee: params[:end_fee])

    #⑤入力された値の型が正否、値の大きさの正否の判定　正しい場合のみ処理を行う
    if params[:owned_quantity].to_i > 0 &&
      params[:owned_quantity].to_s.match?(/\A[0-9]+\z/) &&
      params[:end_date].present? &&
      params[:end_price].to_f > 0 &&
      params[:end_price].match?(/\A[-]?[0-9]+(\.[0-9]+)?\z/) &&
      params[:end_fee].to_s.match?(/\A[0-9]+\z/)
      
      #⑥stocksテーブルの保有銘柄情報をpeformanceテーブルの保有履歴情報に挿入
      @performance.user_id = @stock.user_id
      @performance.trade_id = @stock.id
      @performance.stock_code = @stock.stock_code
      @performance.market_category = @stock.market_category
      @performance.stock_name = @stock.stock_name
      @performance.transaction_type = @stock.transaction_type
      @performance.start_date = @stock.start_date
      @performance.start_price = @stock.start_price
      @performance.memo = @stock.memo

      #⑦各種計算処理
      #決済数量を元に決済数量の開始総額を計算する
      @performance.start_amount = @performance.owned_quantity.to_i * @stock.start_price.to_f
      
      #決済総額・決済単価・損益率・損益額の計算
      #買いの場合
      if @performance.transaction_type != "03"
        #決済総額取得
        @performance.end_amount = (@performance.owned_quantity.to_i * @performance.end_price.to_f) - @performance.end_fee.to_i
        #決済単価取得
        @performance.end_price = @performance.end_amount.to_f / @performance.owned_quantity.to_f
        #損益率計算
        @performance.pl_ratio = (@performance.end_price.to_f / @performance.start_price.to_f - 1) * 100
        #損益額計算
        @performance.pl_amount = (@performance.end_price.to_f - @performance.start_price.to_f) * @performance.owned_quantity.to_i
      #売りの場合
      elsif @performance.transaction_type == "03"
        #決済総額取得
        @performance.end_amount = (@performance.owned_quantity.to_i * @performance.end_price.to_f) + @performance.end_fee.to_i
        #決済単価取得
        @performance.end_price = @performance.end_amount.to_f / @performance.owned_quantity.to_f
        #損益率計算
        @performance.pl_ratio = (1 - (@performance.end_price.to_f / @performance.start_price.to_f)) * 100
        #損益額計算
        @performance.pl_amount = (@performance.start_price.to_f - @performance.end_price.to_f) * @performance.owned_quantity.to_i
      end

      #⑧全額決済の場合のperformances、usersへの書き込み、stocksの保有銘柄情報の削除(E)
      if @stock.owned_quantity == @performance.owned_quantity
        if @performance.save && @stock.destroy
          flash[:liquidation] = "保有銘柄の全決済処理を行いました！"
          flash[:id] = @performance.id
          #実現譲渡損益の計算と書き込み
          stock_pl_amount_set
          redirect_to("/performances")
          #redirect_to("/")
        else
          render("stocks/operation")
        end
      #⑧部分決済のperformances、stocks、usersへの書き込み(E)
      elsif @stock.owned_quantity >= @performance.owned_quantity
        #保有株数 = 保有株数 - 決済株数
        @stock.owned_quantity = @stock.owned_quantity - @performance.owned_quantity
        @stock.start_amount -= @performance.start_amount
        if @performance.save && @stock.save
          flash[:liquidation] = "保有銘柄の部分決済処理を行いました！"
          flash[:id] = @performance.id
          #実現譲渡損益の計算と書き込み
          stock_pl_amount_set
          redirect_to("/performances")
          #redirect_to("/stocks/#{params[:id]}/operation")
        else
          render("stocks/operation")
        end  
      #⑧決済数量が保有数量を超えている場合のエラー処理(E)
      else
          @errors_message.push("決済数量が保有数量を超えています")
          render("stocks/operation")
      end

    #⑥エラー確定 エラーメッセージ出力(E)
    else
      #決済数量が保有数量を超えている場合のエラーメッセージ付与
      if params[:owned_quantity].to_i > @stock.owned_quantity
        @errors_message.push("決済数量が保有数量を超えています！")
      end

      if @performance.save
        #バグ確定
        flash[:error] = "不正なデータ更新が行われました"
        redirect_to("/stocks/#{params[:id]}/operation")
      else
        render("stocks/operation")
      end
    end
  end

  #performanceビューの元保有銘柄一覧表より-------------------------------------------------------------------
  def stock_operation
    #レンダー処理用値設定
    render_pack2

    #銘柄編集タブボックス初期値設定
    @tab_select = "01"
  end

  #edit_eビューの決済ボタンより------------------------------------------------------------------
  def update
    #①レンダー処理用値設定
    @tab_select = "05"
    render_pack2

    #②「決済単価」か「約定単価」かの判定 「取得単価」の場合はparams[:end_fee]に０を挿入 
    @price_type = params[:price_type]
    price_type_checker2

    #③入力フォームの決済情報データをインスタンス変数に格納
    @performance.owned_quantity = params[:owned_quantity]
    @performance.end_date = params[:end_date]
    @performance.end_price = params[:end_price]
    @performance.end_fee = params[:end_fee]

    #④入力された値の型が正否、値の大きさの正否の判定　正しい場合のみ処理を行う
    if params[:owned_quantity].to_i > 0 &&
      params[:owned_quantity].to_s.match?(/\A[0-9]+\z/) &&
      params[:end_date].present? &&
      params[:end_price].to_f > 0 &&
      params[:end_price].match?(/\A[-]?[0-9]+(\.[0-9]+)?\z/) &&
      params[:end_fee].to_s.match?(/\A[0-9]+\z/)

      #⑤各種計算処理
      #決済総額・決済単価・損益率・損益額の計算
      #買いの場合
      if @performance.transaction_type != "03"
        #決済総額取得
        @performance.end_amount = (params[:owned_quantity].to_i * params[:end_price].to_f) - params[:end_fee].to_i
        #決済単価取得
        @performance.end_price = @performance.end_amount.to_f / params[:owned_quantity].to_i
        #損益率計算
        @performance.pl_ratio = (@performance.end_price.to_f / @performance.start_price.to_f - 1) * 100
        #損益額計算
        @performance.pl_amount = (@performance.end_price.to_f - @performance.start_price.to_f) * params[:owned_quantity].to_i
      #売りの場合
      elsif @performance.transaction_type == "03"
        #決済総額取得
        @performance.end_amount = (params[:owned_quantity].to_i * params[:end_price].to_f) + params[:end_fee].to_i
        #決済単価取得
        @performance.end_price = @performance.end_amount.to_f / params[:owned_quantity].to_i
        #損益率計算
        @performance.pl_ratio = (1 - (@performance.end_price.to_f / @performance.start_price.to_f)) * 100
        #損益額計算
        @performance.pl_amount = (@performance.start_price.to_f - @performance.end_price.to_f) * params[:owned_quantity].to_i
      end

      #⑥編集情報の書き込み(E)
      if @performance.save
        flash[:performance_update] = "決済済み銘柄の決済情報を編集しました"
        #実現譲渡損益の計算と書き込み
        stock_pl_amount_set
        redirect_to("/performances/#{params[:id]}/stock_operation")
      else
        render("/performances/stock_operation")
      end

    #⑥エラー確定 エラーメッセージ出力(E)
    else
      if @performance.save
        #バグ確定
        flash[:error] = "不正なデータ更新が行われました"
        redirect_to("/performances/#{params[:id]}/stock_operation")
      else
        render("/performances/stock_operation")
      end
    end
  end

  #memoビューの登録ボタンより---------------------------------------------------------------------------
  def memo_update

    #①レンダー処理用値設定(S)
    @tab_select = "06"
    render_pack2

    #②インスタンス変数にデータ格納
    @performance.memo = params[:memo]

    #③DB書き込み(E)
    if @performance.save
      flash[:memo_update] = "メモを更新しました"
      redirect_to("/performances/#{params[:id]}/stock_operation")
    else
      render("/performances/stock_operation")
    end
  end

  #destroyビューの登録ボタンより-------------------------------------------------------------------------
  def destroy

    #①レンダー処理用値設定(S)
    @tab_select = "07"
    render_pack2

    #②レコード削除(E)
    if @performance.destroy
      flash[:update] = "決済済み銘柄情報を削除しました"
      redirect_to("/performances")
    else
      render("/performances/stock_operation")
    end
  end

  #performanceビューの配当等一覧表より-------------------------------------------------------------------
  def dividend_operation
    #レンダー処理用値設定
    render_pack3

    #銘柄編集タブボックス初期値設定
    @tab_select = "01"
  end
  #dividend_memoビューの登録ボタンより---------------------------------------------------------------------------
  def dividend_memo_update

    #①レンダー処理用値設定(S)
    @tab_select = "06"
    render_pack3

    #②インスタンス変数にデータ格納
    @dividend.memo = params[:memo]

    #③DB書き込み(E)
    if @dividend.save
      flash[:memo_update] = "メモを更新しました"
      redirect_to("/performances/#{params[:id]}/dividend_operation")
    else
      render("/performances/dividend_operation")
    end
  end
  #dividend_destroyビューの登録ボタンより-------------------------------------------------------------------------
  def dividend_destroy

    #①レンダー処理用値設定(S)
    @tab_select = "07"
    render_pack3

    #②レコード削除(E)
    if @dividend.destroy
      flash[:update] = "配当情報を削除しました"
      redirect_to("/performances")
    else
      render("/performances/dividend_operation")
    end
  end
end

