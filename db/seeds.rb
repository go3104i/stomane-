require 'csv'
 
CSV.foreach('db/data_Stockmaster.csv',encoding: 'Shift_JIS:UTF-8',headers: true) do |row|
  Stockmaster.create!(
    update_date: row['update_date'],
    stock_code: row['stock_code'],
    stock_name: row['stock_name'],
    market_category: row['market_category'],
    industry_code_33: row['industry_code_33'],
    industry_category_33: row['industry_category_33'],
    industry_code_17: row['industry_code_17'],
    industry_category_17: row['industry_category_17'],
    scale_code: row['scale_code'],
    scale_category: row['scale_category']
  )
end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
