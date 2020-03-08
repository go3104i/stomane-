class Performance < ApplicationRecord
  #数値で０以上かつ整数であること
  #validates :owned_quantity, presence: true, numericality: { greater_than_or_equal_to: 0,only_integer: true }
  validates :owned_quantity, presence: true, numericality: { greater_than: 0,only_integer: true }

  validates :end_date, presence: true

  #０より大きいこと
  validates :end_price, presence: true, numericality: { greater_than: 0 }

  #数値で０以上かつ整数であること
  validates :end_fee, presence: true, numericality: { greater_than_or_equal_to: 0,only_integer: true }

  #ブランクやnilでないこと
  with_options presence: true do
  #validates :trade_id, presence: true
  #validates :stock_code, presence: true
  #validates :stock_name, presence: true
  #validates :transaction_type, presence: true
  #validates :start_date, presence: true
  #validates :start_price, presence: true
  #validates :start_fee, presence: true
  # validates :start_amount, presence: true
  # validates :end_amount, presence: true
  # validates :pl_ratio, presence: true
  # validates :pl_amount, presence: true
  end
  #銘柄コードは４文字のみ
  #validates :stock_code, length: { is: 4 }
end
