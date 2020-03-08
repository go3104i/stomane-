class ApplicationController < ActionController::Base
  #レンダー時にpossession_informationビューに表示するデータを格納----------------------------------------------
  def render_pack
    @errors_message = Array.new
    @liquidation_type = "01"
    @price_type = "01"
    @performance = Performance.new
    @dividend_target = "01"
    @dividend = Dividend.new
    @stock_render = Stock.new
    @stock = Stock.find_by(id: params[:id])
    @stock_code = @stock.stock_code
    @market_category = @stock.market_category
    @stock_name = @stock.stock_name
    @transaction_type = @stock.transaction_type
    @owned_quantity = @stock.owned_quantity
    @start_date = @stock.start_date
    @start_price = @stock.start_price
    @start_amount = @stock.start_amount
    @closing_price = @stock.closing_price
    @memo = @stock.memo
  end

  #手数料・諸費用のラジオボタンが「損益計算に含めない」にチェックされている場合にparams[:start_fee]に０を挿入-----------
  def price_type_checker1
    if @price_type == "01"
      params[:start_fee] = 0
    elsif @price_type == "02"
    end
  end
  #手数料・諸費用のラジオボタンが「損益計算に含めない」にチェックされている場合にparams[:end_fee]に０を挿入-----------
  def price_type_checker2
    if @price_type == "01"
      params[:end_fee] = 0
    elsif @price_type == "02"
    end
  end

  #実現譲渡損益計算と書き込み
  def stock_pl_amount_set
    user = User.find_by(user_id: session[:user_id])
    performances = Performance.where(user_id: session[:user_id])

    user.stock_pl_amount = 0
    performances.each do |performance|
      user.stock_pl_amount += performance.pl_amount
    end
    
    user.save
  end

  #実現配当損益計算と書き込み
  def dividend_pl_amount_set
    user = User.find_by(user_id: session[:user_id])
    dividends = Dividend.where(user_id: session[:user_id])

    user.dividend_pl_amount = 0
    dividends.each do |dividend|
      user.dividend_pl_amount += dividend.dividend_amount
    end
    
    user.save
  end

  #実現譲渡損益と実現配当損益の計算と書き込み
  def sd_pl_amount_set
    user = User.find_by(user_id: session[:user_id])
    
    performances = Performance.where(user_id: session[:user_id])
    user.stock_pl_amount = 0
    performances.each do |performance|
      user.stock_pl_amount += performance.pl_amount
    end

    dividends = Dividend.where(user_id: session[:user_id])
    user.dividend_pl_amount = 0
    dividends.each do |dividend|
      user.dividend_pl_amount += dividend.dividend_amount
    end
    
    user.save
  end  

  #レンダー時にperformance_informationビューに表示するデータを格納----------------------------------------------
  def render_pack2
    @errors_message = Array.new
    @price_type = "01"
    @dividend_target = "01"
    @dividend = Dividend.new
    @performance = Performance.find_by(id: params[:id])
    @stock_code = @performance.stock_code
    @market_category = @performance.market_category
    @stock_name = @performance.stock_name
    @transaction_type = @performance.transaction_type
    @owned_quantity = @performance.owned_quantity
    @start_date = @performance.start_date
    @start_price = @performance.start_price
    @start_amount = @performance.start_amount
    @end_date = @performance.end_date
    @end_price = @performance.end_price
    @memo = @performance.memo
  end

  #レンダー時にperformance_informationビューに表示するデータを格納----------------------------------------------
  def render_pack3
    @errors_message = Array.new
    @price_type = "01"
    @dividend_target = "01"
    @dividend = Dividend.find_by(id: params[:id])
    @stock_code = @dividend.stock_code
    @market_category = @dividend.market_category
    @stock_name = @dividend.stock_name
    @dividend_type = @dividend.dividend_type
    @dividend_quantity = @dividend.dividend_quantity
    @dividend_q = @dividend.dividend_quantity
    @dividend_date = @dividend.dividend_date
    @dividend_d = @dividend.dividend_date
    @dividend_price = @dividend.dividend_price
    @dividend_p = @dividend.dividend_price
    @dividend_amount = @dividend.dividend_amount
    @dividend_a = @dividend.dividend_amount
    @dividend_a_sell = -1 * @dividend.dividend_amount
    @season = @dividend.season
    @dividend_s = @dividend.season
    @memo = @dividend.memo
  end
end
