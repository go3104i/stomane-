# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_07_031541) do

  create_table "dividends", force: :cascade do |t|
    t.string "user_id"
    t.string "stock_code"
    t.string "stock_name"
    t.string "market_category"
    t.string "dividend_type"
    t.integer "dividend_quantity"
    t.date "dividend_date"
    t.float "dividend_price"
    t.integer "dividend_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "season"
    t.text "memo"
  end

  create_table "performances", force: :cascade do |t|
    t.string "user_id"
    t.string "trade_id"
    t.string "stock_code"
    t.string "stock_name"
    t.string "transaction_type"
    t.integer "owned_quantity"
    t.date "start_date"
    t.float "start_price"
    t.integer "start_amount"
    t.date "end_date"
    t.float "end_price"
    t.integer "end_fee"
    t.integer "end_amount"
    t.float "pl_ratio"
    t.integer "pl_amount"
    t.text "memo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "market_category"
  end

  create_table "stockmasters", force: :cascade do |t|
    t.string "update_date"
    t.string "stock_code"
    t.string "stock_name"
    t.string "market_category"
    t.string "industry_code_33"
    t.string "industry_category_33"
    t.string "industry_code_17"
    t.string "industry_category_17"
    t.string "scale_code"
    t.string "scale_category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "stocks", force: :cascade do |t|
    t.string "user_id"
    t.string "trade_id"
    t.string "stock_code"
    t.string "stock_name"
    t.string "transaction_type"
    t.integer "owned_quantity"
    t.date "start_date"
    t.float "start_price"
    t.integer "start_fee"
    t.integer "start_amount"
    t.float "closing_price"
    t.float "pl_ratio"
    t.integer "pl_amount"
    t.text "memo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "market_category"
    t.string "price_type"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_id"
    t.string "password_digest"
    t.string "user_name"
    t.integer "stock_pl_amount"
    t.integer "dividend_pl_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
