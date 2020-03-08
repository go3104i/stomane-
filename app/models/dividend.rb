class Dividend < ApplicationRecord
  validates :stock_code, presence: true
  validates :stock_name, presence: true
  validates :market_category, presence: true
  validates :dividend_type, presence: true
  validates :dividend_date, presence: true
  #数値で０より大きくかつ整数であること ブランクOK
  validates :dividend_quantity, numericality: { greater_than: 0,only_integer: true },allow_blank: true
  #数値で０より大きいこと　ブランクOK
  validates :dividend_price, numericality: { greater_than: 0 },allow_blank: true
  #整数であること
  validates :dividend_amount, presence: true, numericality: { only_integer: true }
end
