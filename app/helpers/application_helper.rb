module ApplicationHelper
  #数値の後ろに「円」をつける
  def yen_helper(money)
    "#{money}円"
  end

  #整数の場合は小数型を整数型に
  def seisho_helper(seisho)
    if seisho.nil? then
      seisho    
    elsif seisho % 1 == 0 then
      seisho.to_i
    else
      seisho
    end
  end

  #カラム名 transaction_type の数値から取引種別を取得
  def transaction_type_helper(transaction_type)
    if transaction_type == "01"
      transaction_type = "現物買"
    elsif transaction_type == "02"
      transaction_type = "信用買"
    elsif transaction_type == "03"
      transaction_type = "信用売"
    elsif transaction_type == "04"
      transaction_type = "NISA買"
    end
  end

  #カラム名 dividend_type の数値から配当種別を取得
  def dividend_type_helper(dividend_type)
    if dividend_type == "01"
      dividend_type = "株主配当"
    elsif dividend_type == "02"
      dividend_type = "配当落調整金"
    elsif dividend_type == "03"
      dividend_type = "配当落調整金"
    elsif dividend_type == "04"
      dividend_type = "株主配当"
    end
  end

  #カラム名 season の数値から時期区分を取得
  def season_helper(season)
    if season == "01"
      season = "期末"
    elsif season == "02"
      season = "中間"
    elsif season == "03"
      season = "四半期"
    end
  end
end
