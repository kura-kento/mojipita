class ApplicationController < ActionController::Base
  #確定
  MOJI = {moji: 'あいいいいううううえおかかききくくけここささしししすすせそたたちちつつてととなにぬねのはひふへほまみむめもやゆゆよららりりるるれろわんんんんーー'}
  #BOARD_ACTION = {name: false,position: false}
  PLAYERS = {user_id: [128]}
  #削除予定
  WAIT = {player: 0,join: 0,set:false}
  HOLD ={id: false}
  before_action :set_current_player

  def turnplayer
    if PLAYERS[:user_id][0] == session[:user_id]
      redirect_to("/game_start/#{session[:user_id]}")
    end
  end

  def otherplayers
    if PLAYERS[:user_id][0] != session[:user_id]
      redirect_to("/game_start/#{session[:user_id]}")
    end
  end

  def Backup
    BoardHold.all.each{|i| i.delete}
    6.times{ |i|  BoardHold.create(height:Board.all.sort[i].height,width:Board.all.sort[i].width)}
    PlayerHold.all.each{|i| i.delete}
    Player.all.size.times{ |i|  PlayerHold.create(id: Player.all.sort[i].id, name: Player.all.sort[i].name,hand:Player.all.sort[i].hand)}

  end
  def Rollback
      Board.all.each{|i| i.delete}
      6.times{ |i|  Board.create(height:BoardHold.all.sort[i].height,width:BoardHold.all.sort[i].width)}
      Player.all.each{|i| i.delete}
      PlayerHold.all.size.times{ |i|  Player.create(id: PlayerHold.all.sort[i].id, name: PlayerHold.all.sort[i].name,hand:PlayerHold.all.sort[i].hand)}

  end

  def players_zero
    if Player.all.size == 0
      flash[:notice] = "ホストプレイヤーが居ません。"
      redirect_to("/")
    end
  end

  def session_id
    if session[:user_id] != params[:user_id].to_i
      flash[:notice] = "権限がありません。"
      redirect_to("/")
    end
  end

  def set_current_player
      @current_player = Player.find_by(id: session[:user_id])
  end



end
