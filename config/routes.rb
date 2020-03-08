Rails.application.routes.draw do

  get 'users/account_info'
  #インクリメンタルサーチ
  get 'stocks/search' =>  'stocks#search'

  get '/' =>  'stocks#possession'

  get 'stocks/new' =>  'stocks#new'
  post 'stocks/new/create' => 'stocks#create'

  get 'stocks/:id/operation' => 'stocks#operation'
  post 'stocks/:id/operation/liquidation_update' => 'performances#liquidation_update'
  post 'stocks/:id/operation/increase_update' => 'stocks#increase_update'
  post 'stocks/:id/operation/dividend_create' => 'dividends#dividend_create'
  post 'stocks/:id/operation/dividend_cs_create' => 'dividends#dividend_cs_create'
  post 'stocks/:id/operation/dividend_cb_create' => 'dividends#dividend_cb_create'
  post 'stocks/:id/operation/update' => 'stocks#update'
  post 'stocks/:id/operation/memo_update' => 'stocks#memo_update'
  post 'stocks/:id/operation/destroy' => 'stocks#destroy'
  
  get 'performances' => 'performances#performances'

  get 'performances/:id/stock_operation' => 'performances#stock_operation'
  post 'performances/:id/stock_operation/performance_dividend_create' => 'dividends#performance_dividend_create'
  post 'performances/:id/stock_operation/performance_dividend_cs_create' => 'dividends#performance_dividend_cs_create'
  post 'performances/:id/stock_operation/performance_dividend_cb_create' => 'dividends#performance_dividend_cb_create'
  post 'performances/:id/stock_operation/update' => 'performances#update'
  post 'performances/:id/stock_operation/memo_update' => 'performances#memo_update'
  post 'performances/:id/stock_operation/destroy' => 'performances#destroy'

  get 'performances/:id/dividend_operation' => 'performances#dividend_operation'
  post 'performances/:id/dividend_operation/dividend_update' => 'dividends#dividend_update'
  post 'performances/:id/dividend_operation/dividend_cs_update' => 'dividends#dividend_cs_update'
  post 'performances/:id/dividend_operation/dividend_cb_update' => 'dividends#dividend_cb_update'
  
  post 'performances/:id/dividend_operation/dividend_memo_update' => 'performances#dividend_memo_update'
  post 'performances/:id/dividend_operation/dividend_destroy' => 'performances#dividend_destroy'

  #作業中→OK
  #post 'dividends/:id/dividend_create' => 'dividends#dividend_create'
  #post 'dividends/:id/dividend_cs_create' => 'dividends#dividend_cs_create'
  #post 'dividends/:id/dividend_cb_create' => 'dividends#dividend_cb_create'
  

  get 'users/account_info' => 'users#account_info'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
