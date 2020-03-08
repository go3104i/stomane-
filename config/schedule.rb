# ログ出力先ファイルを指定
set :output, 'log/crontab.log'

# ジョブ実行環境を指定 本番環境 → production  開発環境 → development
ENV['RAILS_ENV'] ||= 'development'
set :environment, ENV['RAILS_ENV']
  #以下の記述でも動く？
  #set :environment, :production
  #set :environment, :development 

#実行間隔 　↓１時間に一回　１分に一回 → every 1.minutes do
every 1.day, :at => '3:30 pm' do
  # Rails内のメソッド実行　'コントローラ名.メソッド名'
  runner 'StocksController.price_geter_all'
end


# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
