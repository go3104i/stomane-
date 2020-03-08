class Stock < ApplicationRecord
  validates :stock_code, presence: true
  validates :stock_name, presence: true
  validates :transaction_type, presence: true

  #数値で０より大きくかつ整数であること
  validates :owned_quantity, presence: true, numericality: { greater_than: 0,only_integer: true }

  validates :start_date, presence: true

  #数値で０より大きいこと
  validates :start_price, presence: true, numericality: { greater_than: 0 }
  
  #数値で０以上かつ整数であること
  validates :start_fee, presence: true, numericality: { greater_than_or_equal_to: 0,only_integer: true }

  #validates :start_amount, presence: true
  #validates :closing_price, presence: true

  #銘柄コードは４文字のみ
  #validates :stock_code, length: { is: 4 }
end
