class ApplicationController < ActionController::Base
  WAIT = {player: 0,join: 0}
  MOJI = {moji: 'あいいいいううううえおかかききくくけここささしししすすせそたたちちつつてととなにぬねのはひふへほまみむめもやゆゆよららりりるるれろわんんんんーー'}
  HAND_ACTION = {name: false,position: false}
  BOARD_ACTION = {name: false,position: false}
  HOLD ={id: false}
  TURN = {count: 0}
  JUDGE={maru: 0,batu:0}
  
  def turnplayer
    if Player.all.sort[(TURN[:count] % Player.all.size)].user_id == session[:user_id]
      redirect_to("/game_start/#{session[:user_id]}")
    end
  end

  def otherplayers
    if Player.all.sort[(TURN[:count] % Player.all.size)].user_id != session[:user_id]
      redirect_to("/game_start/#{session[:user_id]}")
    end
  end
end
