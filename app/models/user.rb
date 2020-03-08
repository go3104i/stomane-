class User < ApplicationRecord
  validates :stock_pl_amount, presence: true
end
