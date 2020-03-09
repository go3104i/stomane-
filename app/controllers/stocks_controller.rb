class StocksController < ApplicationController
  
  #トップ画面------------------------------------------------------------------------------------------
  def possession
    #仮のユーザーIDを付与　ユーザーID機能実装後に削除
    session[:user_id] = "3"

    #ユーザー情報読み込み
    @user = User.find_by(user_id: session[:user_id])
    if @user == nil
      @user = User.new(user_id: session[:user_id])
      @user.save
    end

    #ユーザーIDと一致する最初のレコードを抽出
    @stocks = Stock.find_by(user_id: session[:user_id])
    #ユーザーIDと一致するレコードが１行でもある場合、ユーザーIDと一致する全レコードを抽出
    if @stocks != nil
      @stocks = Stock.where(user_id: session[:user_id]).order(start_date: "ASC")
    end

    #総合損益　初期化
    @total_Valuation_pl = 0
  end

  #possessionビューの保有銘柄一覧表より-------------------------------------------------------------------
  def operation
    #レンダー処理用値設定
    render_pack
    @stock_render = Stock.new

    #銘柄編集タブボックス初期値設定
    @tab_select = "01"
  end
  
  #possessionビューの新規登録ボタンより-------------------------------------------------------------------
  def new
    @stock = Stock.new
    #取得単価ラジオボタン初期値設定
    @price_type = "01"
    #エラーメッセージ用変数宣言
    @errors_message = Array.new
  end

  #newビューの登録ボタンより-----------------------------------------------------------------------------
  def create
    #①エラーメッセージ用変数宣言
    @errors_message = Array.new

    #②「取得単価」か「約定単価」かの判定 「取得単価」の場合はparams[:start_fee]に０を挿入 
    @price_type = params[:price_type]
    price_type_checker1

    #③ユーザーIDと入力フォームのデータをインスタンス変数に格納
    @stock = Stock.new(
      user_id: session[:user_id],
      stock_code: params[:stock_code],
      market_category: params[:market_category],
      stock_name: params[:stock_name],
      transaction_type: params[:transaction_type],
      owned_quantity: params[:owned_quantity],
      start_date: params[:start_date],
      start_price: params[:start_price],
      start_fee: params[:start_fee],
      price_type: params[:price_type])

    #④入力された値の型が正否、値の大きさの正否の判定　正しい場合のみ処理を行う
    if params[:owned_quantity].to_i > 0 &&
      params[:owned_quantity].match?(/\A[0-9]+\z/) &&
      params[:start_date].present? &&
      params[:start_price].to_f > 0 &&
      params[:start_price].match?(/\A[-]?[0-9]+(\.[0-9]+)?\z/) &&
      params[:start_fee].to_s.match?(/\A[0-9]+\z/)
      
      #⑤各種計算処理
      #開始総額取得＆開始価格取得
      #買いの場合
      if @stock.transaction_type != "03"
        @stock.start_amount = (@stock.owned_quantity.to_i * @stock.start_price.to_f) + @stock.start_fee.to_i
      #売りの場合
      elsif @stock.transaction_type == "03"
        @stock.start_amount = (@stock.owned_quantity.to_i * @stock.start_price.to_f) - @stock.start_fee.to_i
      end
      @stock.start_price = @stock.start_amount.to_f / @stock.owned_quantity.to_f

      #price_geterで前日終値取得
      if @stock.closing_price = price_geter(@stock.stock_code).to_f
      else
        @errors_message.push("時価の取得に失敗しました")
        render("/stocks/new")
      end

      #⑥DB書き込み＆エラーチェック(E)
      if @stock.save
        flash[:update] = "新規銘柄を登録しました！"
        flash[:id] = @stock.id
        redirect_to("/")
      else
        render("/stocks/new")
      end

    #⑤エラー確定 エラーメッセージ出力(E)
    else
      if @stock.save
        #バグ確定
        flash[:error] = "不正なレコードが作成されました"
        redirect_to("/")
      else
        render("/stocks/new")
      end
    end
  end

  #increaseビューの追加ボタンより------------------------------------------------------------------------
  def increase_update

    #①レンダー処理用値設定
    @tab_select = "03"
    render_pack

    #②「取得単価」か「約定単価」かの判定 「取得単価」の場合はparams[:start_fee]に０を挿入 
    @price_type = params[:price_type]
    price_type_checker1
    
    #③入力された値の型が正否、値の大きさの正否の判定　正しい場合のみ処理を行う
    if params[:owned_quantity].to_i > 0 &&
      params[:owned_quantity].match?(/\A[0-9]+\z/) &&
      params[:start_price].to_f > 0 &&
      params[:start_price].match?(/\A[-]?[0-9]+(\.[0-9]+)?\z/) &&
      params[:start_fee].to_i >= 0 &&
      params[:start_fee].to_s.match?(/\A[0-9]+\z/)
      
      #④各種計算処理
      @stock = Stock.find_by(id: params[:id])
      #追加取得総額をこれまでの取得総額と合算
      #買いの場合
      if @stock.transaction_type != "03"
        @stock.start_amount += (params[:owned_quantity].to_i * params[:start_price].to_f) + params[:start_fee].to_i
      #売りの場合
      elsif @stock.transaction_type == "03"
        @stock.start_amount += (params[:owned_quantity].to_i * params[:start_price].to_f) - params[:start_fee].to_i
      end

      #追加取得数をこれまでの保有数量と合算
      @stock.owned_quantity = @stock.owned_quantity + params[:owned_quantity].to_i
      #平均取得単価を計算
      @stock.start_price = @stock.start_amount.to_f / @stock.owned_quantity.to_i
      #price_geterで前日終値取得
      @stock.closing_price = price_geter(@stock.stock_code).to_f
      
      #⑤DB書き込み＆エラーチェック(E)
      if @stock.save
        flash[:increase] = "保有銘柄の情報を更新しました！"
        redirect_to("/stocks/#{params[:id]}/operation")
      else
        render("stocks/operation")
      end
    #④エラー確定 エラーメッセージ出力(E)
    else
      #エラーメッセージ出力用ダミーデータ作成
      @stock_render = Stock.new(
        stock_code: "0000",
        stock_name: "ダミー",
        transaction_type: "00",
        owned_quantity: params[:owned_quantity],
        start_date: 2100-01-01,
        start_price: params[:start_price],
        start_fee: params[:start_fee])
      if @stock_render.save
        #バグ確定
        flash[:error] = "不正なレコードが作成されました"
        redirect_to("/stocks/#{params[:id]}/operation")
      else
        render("stocks/operation")
      end
    end
  end

  #editビューの登録ボタンより----------------------------------------------------------------------------
  def update

    #①レンダー処理用値設定(S)
    @tab_select = "05"
    render_pack

    #②「取得単価」か「約定単価」かの判定 「取得単価」の場合はparams[:start_fee]に０を挿入 
    @price_type = params[:price_type]
    price_type_checker1

    #③データ格納（バリデーションエラーの場合のメッセージ出力用も兼ねる）
    @stock.transaction_type = params[:transaction_type]
    @stock.owned_quantity = params[:owned_quantity]
    @stock.start_date = params[:start_date]
    @stock.start_price = params[:start_price]
    @stock.start_fee = params[:start_fee]

    #④入力された値の型の正否、値の大きさの正否の判定　正しい場合のみ処理を行う
    if params[:owned_quantity].to_i > 0 &&
      params[:owned_quantity].match?(/\A[0-9]+\z/) &&
      params[:start_date].present? &&
      params[:start_price].to_f > 0 &&
      params[:start_price].match?(/\A[-]?[0-9]+(\.[0-9]+)?\z/) &&
      params[:start_fee].to_i >= 0 &&
      params[:start_fee].to_s.match?(/\A[0-9]+\z/)

      #⑤各種計算処理
      #開始総額取得＆開始価格取得
      #買いの場合
      if @stock.transaction_type != "03"
        @stock.start_amount = (params[:owned_quantity].to_i * params[:start_price].to_f) + params[:start_fee].to_i
      #売りの場合
      elsif @stock.transaction_type == "03"
        @stock.start_amount = (params[:owned_quantity].to_i * params[:start_price].to_f) - params[:start_fee].to_i
      end
      @stock.start_price = @stock.start_amount.to_f / params[:owned_quantity].to_i

      #price_geterで前日終値取得
      #if @stock.closing_price = price_geter(@stock.stock_code).to_f
      #else
      #  @errors_message.push("時価の取得に失敗しました")
      #  render("/stocks/new")
      #end

      #⑥DB書き込み＆エラーチェック(E)
      if @stock.save
        flash[:update] = "保有銘柄の情報を更新しました！"
        redirect_to("/stocks/#{params[:id]}/operation")
      else
        render("stocks/operation")
      end
    #⑤エラー確定　エラーメッセージ出力(E)  
    else
      if @stock.save
        #バグ確定
        flash[:error] = "不正なデータ更新が行われました"
        redirect_to("/stocks/#{params[:id]}/operation")
      else
        render("stocks/operation")
      end
    end
  end

  #memoビューの登録ボタンより---------------------------------------------------------------------------
  def memo_update

    #①レンダー処理用値設定(S)
    @tab_select = "06"
    render_pack

    #②インスタンス変数にデータ格納
    @stock.memo = params[:memo]

    #③DB書き込み(E)
    if @stock.save
      flash[:memo_update] = "メモを更新しました"
      redirect_to("/stocks/#{params[:id]}/operation")
    else
      render("stocks/operation")
    end
  end

  #destroyビューの登録ボタンより-------------------------------------------------------------------------
  def destroy

    #①レンダー処理用値設定(S)
    @tab_select = "07"
    render_pack

    #②レコード削除(E)
    if @stock.destroy
      flash[:update] = "保有銘柄情報を削除しました"
      redirect_to("/")
    else
      render("stocks/operation")
    end
  end

  #単一銘柄の株価を自動取得 「みんかぶ」よりスクレイピング-----------------------------------------------------
  def price_geter(code_to_price)
    agent = Mechanize.new

    #①個別銘柄ページにアクセスし、ページ全体の情報を取得(S)
    page = agent.get("https://minkabu.jp/stock/#{code_to_price}")

    #②株価の整数部分を抽出
    elements = page.search('//*[@id="layout"]/div[2]/div[3]/div[2]/div/div[1]/div/div/div[1]/div[2]/div/div[2]/div/text()')
    price = elements[0].text.gsub(/[^\d]/, "").to_i

    #③株価の小数部分を抽出
    elements2 = page.search('//*[@id="layout"]/div[2]/div[3]/div[2]/div/div[1]/div/div/div[1]/div[2]/div/div[2]/div/span[1]')
    price2 = elements2[0].text.gsub(/[^\d]/, "").to_f

    #④小数部分に０以外の値がある場合は小数を算出し整数と小数を足し合わせる(E)
    if price2 == 0 || price2.blank?
      return price
    else
      price2 = price2 / 10
      price += price2
    end
  end


  #全保有銘柄の株価を自動取得し、DBに書き込む　やりすぎ注意　現状バッチ処理のみ-------------------------------------
  def price_geter_all
    stocks = Stock.all.order(created_at: :asc)
    stocks.each do |stock|
      #price_geterで前日終値取得
      stock.closing_price = price_geter(stock.stock_code)
      stock.save
    end
  end

  #インクリメンタルサーチ----------------------------------------------------------------------------------
  def search
    if params[:keyword].blank?
    else
      keyword = params[:keyword].tr('0-9a-zA-Z','０-９ａ-ｚＡ-Ｚ')
      @stock_name = Stockmaster.where('stock_code LIKE(?)', "#{params[:keyword]}%") #paramsとして送られてきたkeyword（入力された語句）で、Userモデルのnameカラムを検索し、その結果を@usersに代入する
      @stock_name += Stockmaster.where('stock_name LIKE(?)',"%#{keyword}%") #paramsとして送られてきたkeyword（入力された語句）で、Userモデルのnameカラムを検索し、その結果を@usersに代入する
      if @stock_name.blank?
      else
        respond_to do |format| 
          format.json { render 'new', json: @stock_name } #json形式のデータを受け取ったら、@usersをデータとして返す そしてindexをrenderで表示する
        end
      end
    end
  end
end
