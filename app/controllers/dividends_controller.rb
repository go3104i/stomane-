class DividendsController < ApplicationController
  #stocks配下のdividendビューの登録ボタンより------------------------------------------------------------------
  def dividend_create
    #①レンダー処理用値設定
    @tab_select = "04"
    render_pack
    @dividend_q = params[:dividend_quantity]
    @dividend_p = params[:dividend_price]

    #②「配当対象株数」の押下ラジオボタンが「全保有銘柄」の時、stocksの保有数量をparams[:dividend_quantity]に格納
    @dividend_target = params[:dividend_target]
    if @dividend_target == "01"
      #正規表現用にstring型で格納
      params[:dividend_quantity] = @stock.owned_quantity.to_s
    end

    #③ユーザーIDと入力フォームの決済情報データをインスタンス変数に格納
    newdata_dividend

    #④stocksテーブルの保有銘柄情報をインスタンス変数に格納
    stock_dividend
    
    #⑤「配当対象株数」「１株当たりの配当金額」の入力有無と入力値正誤判定　正の場合は未入力項目の計算処理、誤の場合はエラーメッセージ付与
    if (params[:dividend_quantity].to_i > 0 || params[:dividend_quantity].blank?) &&
    (params[:dividend_quantity].match?(/\A[0-9]+\z/) || params[:dividend_quantity].blank?) &&
    (params[:dividend_price].to_f > 0 || params[:dividend_price].blank?) &&
    (params[:dividend_price].match?(/\A[-]?[0-9]+(\.[0-9]+)?\z/) || params[:dividend_price].blank?)
    
      #「配当対象株数」に値が入っており、「１株当たりの配当金額」がブランクの時
      if params[:dividend_quantity].present? && params[:dividend_price].blank?
        #「配当対象株数」が正常単位で「税引前配当金総額」が正常な値かどうかを判定し、正しければ「１株あたりの配当金額」計算処理を行い、異常の場合エラーメッセージを格納
        if params[:dividend_quantity].to_i % 100 == 0 &&
        params[:dividend_amount].to_i > 0 &&
        params[:dividend_amount].match?(/\A[0-9]+\z/)
          #「１株当たりの配当金額」を算出、格納
          @dividend.dividend_price = params[:dividend_amount].to_f / params[:dividend_quantity].to_f
        elsif params[:dividend_quantity].to_i % 100 != 0
          @errors_message.push("配当対象株数は１００株単位で入力してください")
        end        

      #「１株当たりの配当金額」に値が入っており、「配当対象株数」がブランクの時
      elsif params[:dividend_price].present? && params[:dividend_quantity].blank?
        #[１枚当たりの配当金額]と[税引前配当金総額]から「配当対象株数」を求め、正常単位かどうか判定し、異常の場合エラーメッセージを格納
        if (params[:dividend_amount].to_f / params[:dividend_price].to_f) % 100 == 0 &&
        params[:dividend_amount].to_i > 0 &&
        params[:dividend_amount].match?(/\A[0-9]+\z/)
          #「配当対象株数」を算出、格納
          @dividend.dividend_quantity = params[:dividend_amount].to_i / params[:dividend_price].to_f
          @dividend.dividend_quantity = @dividend.dividend_quantity.to_i
        elsif (params[:dividend_amount].to_f / params[:dividend_price].to_f) % 100 != 0
          @errors_message.push("１枚当たりの配当金額か税引前配当金総額の数値が異常です")
        end

      #「配当対象株数」と「１株当たりの配当金額」の両方がブランク
      elsif params[:dividend_quantity].blank? && params[:dividend_price].blank?
        @errors_message.push("配当対象株数と１枚当たりの配当金額のいずれか、もしくは両方を入力してください")

      #「配当対象株数」と「１株当たりの配当金額」の両方に値がある
      elsif params[:dividend_quantity].present? && params[:dividend_price].present?
        if params[:dividend_quantity].to_i % 100 != 0
          @errors_message.push("配当対象株数は１００株単位で入力してください")
        end    
      end
    elsif params[:dividend_quantity].to_i % 100 != 0
      @errors_message.push("配当対象株数は１００株単位で入力してください")
    end

    #⑥「税引前配当金総額」の数値判定　※配当落調整金の関係でdividend_amountのバリデーションが０やマイナス数値OKのため、もしこれらに該当する場合ここでエラーメッセージを格納
    if params[:dividend_amount].match?(/\A[0]+\z/) || params[:dividend_amount].to_i < 0
      @errors_message.push("税引前配当金総額は０より大きい数を入力してください")
    end

    #⑦dividentsへの書き込み(E)
    if @dividend.save && @errors_message.blank?
      flash[:dividend] = "配当情報を登録しました！"
      flash[:dividend_id] = @dividend.id
      #実現配当損益の計算と書き込み
      dividend_pl_amount_set
      redirect_to("/performances")
    elsif @dividend.save && @errors_message.present?
      @dividend.destroy
      render("stocks/operation")
    else
      render("stocks/operation")
    end
  end

  #dividend_csビューの登録ボタンより------------------------------------------------------------------
  def dividend_cs_create
    #①レンダー処理用値設定
    @tab_select = "04"
    render_pack

    #②エラー判定　エラーの場合、エラーメッセージ格納　正常の場合、配当金調整額をマイナスに変換
    if params[:dividend_date].blank?
      @errors_message.push("支払日を入力してください")
    end
    
    if params[:dividend_amount].blank?
      @errors_message.push("配当落調整金支払額を入力してください")
    elsif params[:dividend_amount].match?(/\A[0]+\z/)
      @errors_message.push("配当落調整金支払額は０より大きい数を入力してください")
    elsif params[:dividend_amount].to_i < 0
      @errors_message.push("配当落調整金支払額は０より大きい数を入力してください")
    #正常
    elsif params[:dividend_amount].match?(/\A[0-9]+\z/)
      #配当落調整金支払いの為、数値をマイナスに変換
      params[:dividend_amount] = params[:dividend_amount].to_i * -1
    #ブランクでない　０でない　マイナスでない　整数でない場合  
    else
      @errors_message.push("配当落調整金支払額は半角の整数で入力してください")
    end

    #③ユーザーIDと入力フォームの決済情報データをインスタンス変数に格納
    newdata_dividend
    
    #④stocksテーブルの保有銘柄情報をインスタンス変数に格納
    stock_dividend

    #⑤dividentsへの書き込み(E)
    save_possession_c_dividend
  end

  #dividend_cbビューの登録ボタンより------------------------------------------------------------------
  def dividend_cb_create
    #①レンダー処理用値設定
    @tab_select = "04"
    render_pack

    #②エラー判定　エラーの場合、エラーメッセージ格納
    if params[:dividend_date].blank?
      @errors_message.push("受取日を入力してください")
    end
    
    if params[:dividend_amount].blank?
      @errors_message.push("配当落調整金受取額を入力してください")
    elsif params[:dividend_amount].match?(/\A[0]+\z/)
      @errors_message.push("配当落調整金受取額は０より大きい数を入力してください")
    elsif params[:dividend_amount].to_i < 0
      @errors_message.push("配当落調整金受取額は０より大きい数を入力してください")
    #正常
    elsif params[:dividend_amount].match?(/\A[0-9]+\z/)

    #ブランクでない　０でない　マイナスでない　整数でない場合  
    else
      @errors_message.push("配当落調整金受取額は半角の整数で入力してください")
    end

    #③ユーザーIDと入力フォームの決済情報データをインスタンス変数に格納
    newdata_dividend
    
    #④stocksテーブルの保有銘柄情報をインスタンス変数に格納
    stock_dividend

    #⑤dividentsへの書き込み(E)
    save_possession_c_dividend
  end
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #performances配下のdividend ビューの登録ボタンより------------------------------------------------------------------
  def performance_dividend_create
    #①レンダー処理用値設定
    @tab_select = "04"
    render_pack2
    @dividend_q = params[:dividend_quantity]
    @dividend_p = params[:dividend_price]

    #②「配当対象株数」の押下ラジオボタンが「全保有銘柄」の時、stocksの保有数量をparams[:dividend_quantity]に格納
    @dividend_target = params[:dividend_target]
    if @dividend_target == "01"
      #正規表現用にstring型で格納
      params[:dividend_quantity] = @performance.owned_quantity.to_s
    end

    #③ユーザーIDと入力フォームの決済情報データをインスタンス変数に格納
    newdata_dividend

    #④performancesテーブルの決済済み銘柄情報をインスンタンス変数に格納
    performance_dividend
    
    #⑤「配当対象株数」「１株当たりの配当金額」の入力有無と入力値正誤判定　正の場合は未入力項目の計算処理、誤の場合はエラーメッセージ付与
    if (params[:dividend_quantity].to_i > 0 || params[:dividend_quantity].blank?) &&
    (params[:dividend_quantity].match?(/\A[0-9]+\z/) || params[:dividend_quantity].blank?) &&
    (params[:dividend_price].to_f > 0 || params[:dividend_price].blank?) &&
    (params[:dividend_price].match?(/\A[-]?[0-9]+(\.[0-9]+)?\z/) || params[:dividend_price].blank?)
    
      #「配当対象株数」に値が入っており、「１株当たりの配当金額」がブランクの時
      if params[:dividend_quantity].present? && params[:dividend_price].blank?
        #「配当対象株数」が正常単位で「税引前配当金総額」が正常な値かどうかを判定し、正しければ「１株あたりの配当金額」計算処理を行い、異常の場合エラーメッセージを格納
        if params[:dividend_quantity].to_i % 100 == 0 &&
        params[:dividend_amount].to_i > 0 &&
        params[:dividend_amount].match?(/\A[0-9]+\z/)
          #「１株当たりの配当金額」を算出、格納
          @dividend.dividend_price = params[:dividend_amount].to_f / params[:dividend_quantity].to_f
        elsif params[:dividend_quantity].to_i % 100 != 0
          @errors_message.push("配当対象株数は１００株単位で入力してください")
        end        

      #「１株当たりの配当金額」に値が入っており、「配当対象株数」がブランクの時
      elsif params[:dividend_price].present? && params[:dividend_quantity].blank?
        #[１枚当たりの配当金額]と[税引前配当金総額]から「配当対象株数」を求め、正常単位かどうか判定し、異常の場合エラーメッセージを格納
        if (params[:dividend_amount].to_f / params[:dividend_price].to_f) % 100 == 0 &&
        params[:dividend_amount].to_i > 0 &&
        params[:dividend_amount].match?(/\A[0-9]+\z/)
          #「配当対象株数」を算出、格納
          @dividend.dividend_quantity = params[:dividend_amount].to_i / params[:dividend_price].to_f
          @dividend.dividend_quantity = @dividend.dividend_quantity.to_i
        elsif (params[:dividend_amount].to_f / params[:dividend_price].to_f) % 100 != 0
          @errors_message.push("１枚当たりの配当金額か税引前配当金総額の数値が異常です")
        end

      #「配当対象株数」と「１株当たりの配当金額」の両方がブランク
      elsif params[:dividend_quantity].blank? && params[:dividend_price].blank?
        @errors_message.push("配当対象株数と１枚当たりの配当金額のいずれか、もしくは両方を入力してください")

      #「配当対象株数」と「１株当たりの配当金額」の両方に値がある
      elsif params[:dividend_quantity].present? && params[:dividend_price].present?
        if params[:dividend_quantity].to_i % 100 != 0
          @errors_message.push("配当対象株数は１００株単位で入力してください")
        end    
      end
    elsif params[:dividend_quantity].to_i % 100 != 0
      @errors_message.push("配当対象株数は１００株単位で入力してください")
    end

    #⑥「税引前配当金総額」の数値判定　※配当落調整金の関係でdividend_amountのバリデーションが０やマイナス数値OKのため、もしこれらに該当する場合ここでエラーメッセージを格納
    if params[:dividend_amount].match?(/\A[0]+\z/)
      @errors_message.push("税引前配当金総額は０より大きい数を入力してください")
    elsif params[:dividend_amount].to_i < 0
      @errors_message.push("税引前配当金総額は０より大きい数を入力してください")
    end

    #⑦dividentsへの書き込み(E)
    if @dividend.save && @errors_message.blank?
      flash[:dividend] = "配当情報を登録しました！"
      flash[:dividend_id] = @dividend.id
      #実現配当損益の計算と書き込み
      dividend_pl_amount_set
      redirect_to("/performances")
    #バリデーションに引っかからないエラーがある場合
    elsif @dividend.save && @errors_message.present?
      @dividend.destroy
      render("/performances/stock_operation")
    #バリデーションエラーに引っかかった場合
    else
      #バリデーション処理に合わせてparams[:dividend_quantity]とparams[:dividend_price]に整数でない値が入力されていた場合に0を格納してレンダー
      if params[:dividend_quantity].blank? || params[:dividend_quantity].match?(/\A[0-9]+\z/) || params[:dividend_quantity].to_i < 0
      #空白でない、整数でない
      else
        @dividend_q = 0
      end
      if params[:dividend_price].blank? || params[:dividend_price].match?(/\A[-]?[0-9]+(\.[0-9]+)?\z/) || params[:dividend_price].to_f < 0
      #空白でない、整数でない
      else
        @dividend_p = 0
      end
      render("/performances/stock_operation")
    end
  end

  #dividend_csビューの登録ボタンより------------------------------------------------------------------
  def performance_dividend_cs_create
    #①レンダー処理用値設定
    @tab_select = "04"
    render_pack2

    #②エラー判定　エラーの場合、エラーメッセージ格納　正常の場合、配当金調整額をマイナスに変換
    if params[:dividend_date].blank?
      @errors_message.push("支払日を入力してください")
    end
    
    if params[:dividend_amount].blank?
      @errors_message.push("配当落調整金支払額を入力してください")
    elsif params[:dividend_amount].match?(/\A[0]+\z/)
      @errors_message.push("配当落調整金支払額は０より大きい数を入力してください")
    elsif params[:dividend_amount].to_i < 0
      @errors_message.push("配当落調整金支払額は０より大きい数を入力してください")
    #正常
    elsif params[:dividend_amount].match?(/\A[0-9]+\z/)
      #配当落調整金支払いの為、数値をマイナスに変換
      params[:dividend_amount] = params[:dividend_amount].to_i * -1
    #ブランクでない　０でない　マイナスでない　整数でない場合  
    else
      @errors_message.push("配当落調整金支払額は半角の整数で入力してください")
    end

    #③ユーザーIDと入力フォームの決済情報データをインスタンス変数に格納
    newdata_dividend
    
    #④performancesテーブルの決済済み銘柄情報をインスンタンス変数に格納
    performance_dividend

    #⑤dividentsへの書き込み(E)
    save_performance_c_dividend
  end

  #dividend_cbビューの登録ボタンより------------------------------------------------------------------
  def performance_dividend_cb_create
    #①レンダー処理用値設定
    @tab_select = "04"
    render_pack2

    #②エラー判定　エラーの場合、エラーメッセージ格納
    if params[:dividend_date].blank?
      @errors_message.push("受取日を入力してください")
    end
    
    if params[:dividend_amount].blank?
      @errors_message.push("配当落調整金受取額を入力してください")
    elsif params[:dividend_amount].match?(/\A[0]+\z/)
      @errors_message.push("配当落調整金受取額は０より大きい数を入力してください")
    elsif params[:dividend_amount].to_i < 0
      @errors_message.push("配当落調整金受取額は０より大きい数を入力してください")
    #正常
    elsif params[:dividend_amount].match?(/\A[0-9]+\z/)

    #ブランクでない　０でない　マイナスでない　整数でない場合  
    else
      @errors_message.push("配当落調整金受取額は半角の整数で入力してください")
    end

    #③ユーザーIDと入力フォームの決済情報データをインスタンス変数に格納
    newdata_dividend
    
    #④performancesテーブルの決済済み銘柄情報をインスンタンス変数に格納
    performance_dividend

    #⑤dividentsへの書き込み(E)
    save_performance_c_dividend
  end
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #dividend_editビューの登録ボタンより------------------------------------------------------------------
  def dividend_update
    #①レンダー処理用値設定
    @tab_select = "05"
    render_pack3
    #入力データ格納
    @dividend_s = params[:season]
    @dividend_d = params[:dividend_date]
    @dividend_q = params[:dividend_quantity]
    @dividend_p = params[:dividend_price]
    @dividend_a = params[:dividend_amount]

    #②「配当対象株数」の押下ラジオボタンが「全保有銘柄」の時、stocksの保有数量をparams[:dividend_quantity]に格納
    @dividend_target = params[:dividend_target]
    if @dividend_target == "01"
      #正規表現用にstring型で格納
      params[:dividend_quantity] = @stock.owned_quantity.to_s
    end

    #③入力フォームの配当情報データをインスタンス変数に格納
    @dividend.season = params[:season]
    @dividend.dividend_date = params[:dividend_date]
    @dividend.dividend_quantity = params[:dividend_quantity]
    @dividend.dividend_price = params[:dividend_price]
    @dividend.dividend_amount = params[:dividend_amount]
    
    #⑤「配当対象株数」「１株当たりの配当金額」の入力有無と入力値正誤判定　正の場合は未入力項目の計算処理、誤の場合はエラーメッセージ付与
    if (params[:dividend_quantity].to_i > 0 || params[:dividend_quantity].blank?) &&
    (params[:dividend_quantity].match?(/\A[0-9]+\z/) || params[:dividend_quantity].blank?) &&
    (params[:dividend_price].to_f > 0 || params[:dividend_price].blank?) &&
    (params[:dividend_price].match?(/\A[-]?[0-9]+(\.[0-9]+)?\z/) || params[:dividend_price].blank?)
    
      #「配当対象株数」に値が入っており、「１株当たりの配当金額」がブランクの時
      if params[:dividend_quantity].present? && params[:dividend_price].blank?
        #「配当対象株数」が正常単位で「税引前配当金総額」が正常な値かどうかを判定し、正しければ「１株あたりの配当金額」計算処理を行い、異常の場合エラーメッセージを格納
        if params[:dividend_quantity].to_i % 100 == 0 &&
        params[:dividend_amount].to_i > 0 &&
        params[:dividend_amount].match?(/\A[0-9]+\z/)
          #「１株当たりの配当金額」を算出、格納
          @dividend.dividend_price = params[:dividend_amount].to_f / params[:dividend_quantity].to_f
        elsif params[:dividend_quantity].to_i % 100 != 0
          @errors_message.push("配当対象株数は１００株単位で入力してください")
        end        

      #「１株当たりの配当金額」に値が入っており、「配当対象株数」がブランクの時
      elsif params[:dividend_price].present? && params[:dividend_quantity].blank?
        #[１枚当たりの配当金額]と[税引前配当金総額]から「配当対象株数」を求め、正常単位かどうか判定し、異常の場合エラーメッセージを格納
        if (params[:dividend_amount].to_f / params[:dividend_price].to_f) % 100 == 0 &&
        params[:dividend_amount].to_i > 0 &&
        params[:dividend_amount].match?(/\A[0-9]+\z/)
          #「配当対象株数」を算出、格納
          @dividend.dividend_quantity = params[:dividend_amount].to_i / params[:dividend_price].to_f
          @dividend.dividend_quantity = @dividend.dividend_quantity.to_i
        elsif (params[:dividend_amount].to_f / params[:dividend_price].to_f) % 100 != 0
          @errors_message.push("１枚当たりの配当金額か税引前配当金総額の数値が異常です")
        end

      #「配当対象株数」と「１株当たりの配当金額」の両方がブランク
      elsif params[:dividend_quantity].blank? && params[:dividend_price].blank?
        @errors_message.push("配当対象株数と１枚当たりの配当金額のいずれか、もしくは両方を入力してください")

      #「配当対象株数」と「１株当たりの配当金額」の両方に値がある
      elsif params[:dividend_quantity].present? && params[:dividend_price].present?
        if params[:dividend_quantity].to_i % 100 != 0
          @errors_message.push("配当対象株数は１００株単位で入力してください")
        end
      end
    end

    #⑥「税引前配当金総額」の数値判定　※配当落調整金の関係でdividend_amountのバリデーションが０やマイナス数値OKのため、もしこれらに該当する場合ここでエラーメッセージを格納
    if params[:dividend_amount].match?(/\A[0]+\z/)
      @errors_message.push("配当金は０より大きい数を入力してください")
    elsif params[:dividend_amount].to_i < 0
      @errors_message.push("配当金は０より大きい数を入力してください")
    end

    #⑦dividentsへの書き込み(E)
    if @dividend.save && @errors_message.blank?
      flash[:dividend] = "配当情報を変更しました！"
      #実現配当損益の計算と書き込み
      dividend_pl_amount_set
      redirect_to("/performances/#{params[:id]}/dividend_operation")
    elsif @dividend.save && @errors_message.present?
      #@errors_messageが存在する場合はレコードのデータを変更前に戻し再保存→バリデーションエラーメッセージとユニークエラーメッセージを両方出力
      @dividend.season = @season
      @dividend.dividend_date = @dividend_date
      @dividend.dividend_quantity = @dividend_quantity
      @dividend.dividend_price = @dividend_price
      @dividend.dividend_amount = @dividend_amount
      @dividend.save
      render("performances/dividend_operation")
    else
      render("performances/dividend_operation")
    end
  end

  #dividend_cs_editビューの登録ボタンより------------------------------------------------------------------
  def dividend_cs_update
    #①レンダー処理用値設定
    @tab_select = "05"
    render_pack3
    @dividend_a_sell = params[:dividend_amount]

    #②エラー判定　エラーの場合、エラーメッセージ格納　正常の場合、配当金調整額をマイナスに変換
    if params[:dividend_date].blank?
      @errors_message.push("支払日を入力してください")
    end
    
    if params[:dividend_amount].blank?
      @errors_message.push("配当落調整金支払額を入力してください")
    elsif params[:dividend_amount].match?(/\A[0]+\z/)
      @errors_message.push("配当落調整金支払額は０より大きい数を入力してください")
    elsif params[:dividend_amount].to_i < 0
      @errors_message.push("配当落調整金支払額は０より大きい数を入力してください")
    #正常
    elsif params[:dividend_amount].match?(/\A[0-9]+\z/)
      #配当落調整金支払いの為、数値をマイナスに変換
      params[:dividend_amount] = params[:dividend_amount].to_i * -1
    #ブランクでない　０でない　マイナスでない　整数でない場合  
    else
      @errors_message.push("配当落調整金支払額は半角の整数で入力してください")
    end

    #③入力フォームの編集情報データをインスタンス変数に格納
    editdata_dividends
    
    #④dividentsへの書き込み(E)
    save_dividend_c_edit
  end

  #dividend_cb_editビューの登録ボタンより------------------------------------------------------------------
  def dividend_cb_update
    #①レンダー処理用値設定
    @tab_select = "05"
    render_pack3

    #②エラー判定　エラーの場合、エラーメッセージ格納
    if params[:dividend_date].blank?
      @errors_message.push("受取日を入力してください")
    end
    
    if params[:dividend_amount].blank?
      @errors_message.push("配当落調整金受取額を入力してください")
    elsif params[:dividend_amount].match?(/\A[0]+\z/)
      @errors_message.push("配当落調整金受取額は０より大きい数を入力してください")
    elsif params[:dividend_amount].to_i < 0
      @errors_message.push("配当落調整金受取額は０より大きい数を入力してください")
    #正常
    elsif params[:dividend_amount].match?(/\A[0-9]+\z/)

    #ブランクでない　０でない　マイナスでない　整数でない場合  
    else
      @errors_message.push("配当落調整金受取額は半角の整数で入力してください")
    end

    #③入力フォームの編集情報データをインスタンス変数に格納
    editdata_dividends
    
    #④dividentsへの書き込み(E)
    save_dividend_c_edit
  end
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------
  #ユーザーIDと入力フォームの決済情報データをインスタンス変数に格納----------------------------------------
  def newdata_dividend
    @dividend = Dividend.new(      
      user_id: session[:user_id],
      season: params[:season],
      dividend_date: params[:dividend_date],
      dividend_quantity: params[:dividend_quantity],
      dividend_price: params[:dividend_price],
      dividend_amount: params[:dividend_amount])
  end
  #stocksテーブルの決済済み銘柄情報をインスンタンス変数に格納--------------------------------------------
  def stock_dividend
    @dividend.stock_code = @stock.stock_code
    @dividend.stock_name = @stock.stock_name
    @dividend.market_category = @stock.market_category
    @dividend.dividend_type = @stock.transaction_type   
  end

  #performancesテーブルの決済済み銘柄情報をインスンタンス変数に格納--------------------------------------
  def performance_dividend
    @dividend.stock_code = @performance.stock_code
    @dividend.stock_name = @performance.stock_name
    @dividend.market_category = @performance.market_category
    @dividend.dividend_type = @performance.transaction_type
  end

  #保有銘柄の配当落調整金のdividendsへの書き込み------------------------------------------------------
  def save_possession_c_dividend
    if @errors_message.blank?
      if @dividend.save
        flash[:dividend] = "配当落調整金情報を登録しました！"
        flash[:dividend_id] = @dividend.id
        #実現配当損益の計算と書き込み
        dividend_pl_amount_set
        redirect_to("/performances")
      else
        render("stocks/operation")
      end
    else
      render("stocks/operation")
    end
  end

  #決済済み銘柄の配当落調整金のdividendsへの書き込み---------------------------------------------------
  def save_performance_c_dividend
    if @errors_message.blank?
      if @dividend.save
        flash[:dividend] = "配当落調整金情報を登録しました！"
        flash[:dividend_id] = @dividend.id
        #実現配当損益の計算と書き込み
        dividend_pl_amount_set
        redirect_to("/performances")
      else
        render("performances/stock_operation")
      end
    else
      render("performances/stock_operation")
    end
  end

  #編集情報の入力データをインスタンス変数に格納
  def editdata_dividends
    @dividend.season = params[:season]
    @dividend.dividend_date = params[:dividend_date]
    @dividend.dividend_quantity = params[:dividend_quantity]
    @dividend.dividend_price = params[:dividend_price]
    @dividend.dividend_amount = params[:dividend_amount]
  end

  #決済済み銘柄の配当落調整金のdividendsへの書き込み---------------------------------------------------
  def save_dividend_c_edit
    if @errors_message.blank?
      if @dividend.save
        flash[:dividend] = "配当落調整金情報を編集しました！"
        flash[:dividend_id] = @dividend.id
        #実現配当損益の計算と書き込み
        dividend_pl_amount_set
        redirect_to("/performances/#{params[:id]}/dividend_operation")
      else
        render("performances/dividend_operation")
      end
    else
      render("performances/dividend_operation")
    end
  end
    
end

