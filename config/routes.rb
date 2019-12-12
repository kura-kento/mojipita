Rails.application.routes.draw do
  get '/' => 'home#top'
  get '/host_login' => 'home#host_login'
  post '/host_login' => 'home#host_login_check'

  get '/setting' => 'home#setting'
  post '/setting' => 'home#setting_player'
  get '/gerst_login' => 'home#gerst_login'
  post '/gerst_login' => 'home#gerst_login_check'
  get '/wait_area' => 'home#wait_area'
  post '/wait_area' => 'home#wait_area_check'
  post '/board_set' => 'home#board_set'

  get '/game_start/:user_id' => 'game#top'
  post '/action_step1/:position' => 'game#action_step1'
  post '/action_step2/:height/:width' => 'game#action_step2'
  post '/draw/:loglast_id' => 'game#draw'
  post '/judge/:loglast_id' => 'game#judge'

  post '/aggregate' => 'game#aggregate'
  post '/confirm' => 'game#confirm'
  post '/page_update' => 'game#page_update'
  post '/rollback/:loglast_id' => 'game#rollback'
end
