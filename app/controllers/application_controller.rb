class ApplicationController < ActionController::Base
  #確定
  MOJI = {moji: 'あいいいいううううえおかかききくくけここささしししすすせそたたちちつつてととなにぬねのはひふへほまみむめもやゆゆよららりりるるれろわんんんんーー'}
  BOARD_ACTION = {name: false,position: false}
  PLAYERS = {user_id: [0,33]}
  #削除予定
  WAIT = {player: 0,join: 0}
  HOLD ={id: false}
  JUDGE = {maru: 0,batu:0}

  def turnplayer
    if Player.all.sort[(Boardlog.find(1).turn % Player.all.size)].user_id == session[:user_id]
      redirect_to("/game_start/#{session[:user_id]}")
    end
  end

  def otherplayers
    if Player.all.sort[(Boardlog.find(1).turn % Player.all.size)].user_id != session[:user_id]
      redirect_to("/game_start/#{session[:user_id]}")
    end
  end

  def Backup
    BoardHold.all.each{|i| i.delete}
    6.times{ |i|  BoardHold.create(height:Board.all.sort[i].height,width:Board.all.sort[i].width)}
    PlayerHold.all.each{|i| i.delete}
    Player.all.size.times{ |i|  PlayerHold.create(name: Player.all.sort[i].name,user_id: Player.all.sort[i].user_id,hand:Player.all.sort[i].hand)}

  end
  def Rollback
      Board.all.each{|i| i.delete}
      6.times{ |i|  Board.create(height:BoardHold.all.sort[i].height,width:BoardHold.all.sort[i].width)}
      Player.all.each{|i| i.delete}
      PlayerHold.all.size.times{ |i|  Player.create(name: PlayerHold.all.sort[i].name,user_id: PlayerHold.all.sort[i].user_id,hand:PlayerHold.all.sort[i].hand)}

  end


end
