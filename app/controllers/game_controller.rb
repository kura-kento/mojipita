class GameController < ApplicationController
  before_action :otherplayers,{only:[:draw,:action_step1,:judge]}
  before_action :turnplayer,{only:[:aggregate]}
  def top
     @wait= "#{WAIT[:player]},#{WAIT[:join]}"
     @deck = Deck.last.deck
     @boards = Board.all.sort
     @players_name=[]
     Player.all.size.times{|i|
        @players_name << [Player.all[i].name,Player.all[i].hand]
     }
     # 後で変更　更新しないように別枠で書く方がいい
     @player = Player.find_by(user_id: session[:user_id])
     #@players_name.shuffle!

     @numberofdecks = @deck.size
     @turn = TURN[:count]
     @action = HAND_ACTION[:name],HAND_ACTION[:position],BOARD_ACTION[:name],BOARD_ACTION[:position]

     @player_id = Player.all.sort[(TURN[:count] % Player.all.size)].user_id
  end

  def draw
      deck = Deck.last
      player = Player.find_by(user_id: session[:user_id])
      player.hand << deck.deck[0]
      player.save
      deck.deck.slice!(0)
      deck.save

      #ホールドに再登録
      DeckHold.all.each{|i| i.delete}
      DeckHold.create(deck:Deck.last.deck)

      TURN[:count] += 1
      redirect_to("/game_start/#{session[:user_id]}")
  end

  def action_step1
      @boards = Board.all.sort
      if HAND_ACTION[:name] == false
        HAND_ACTION[:name] = params[:action_step1]
        HAND_ACTION[:position] = (params[:hand]).to_i
      end
      @hand_number = (params[:hand]).to_i
      respond_to do |format|
        format.html
        format.js
      end
      #redirect_to("/game_start/#{session[:user_id]}")
  end

  def action_step2

      if HAND_ACTION[:name] != false && params[:action_step2] == "　"

        borad = Board.all.sort[(params[:height]).to_i]
        borad.width[(params[:width]).to_i] = HAND_ACTION[:name]
        borad.save

        player = Player.find_by(user_id: session[:user_id])
        player.hand.slice!(HAND_ACTION[:position])
        player.save

        HAND_ACTION[:name] = false
        HAND_ACTION[:position] = false
        @player = Player.find_by(user_id: session[:user_id])
        @boards = Board.all.sort
        page_update()
      end
        #redirect_to("/game_start/#{session[:user_id]}")
  end
  #集計
  def aggregate
      #現状一人で何回も推せる
      params[:aggregate] == "●" ? JUDGE[:maru] += 1 : JUDGE[:batu] += 1
      redirect_to("/game_start/#{session[:user_id]}")
  end

  def judge
    if Player.all.size-1 <=  JUDGE[:maru] + JUDGE[:batu]
       if  (Player.all.size)-1 <= JUDGE[:maru]
         #次のターンの設定
         TURN[:count] += 1
         # 仮のdbを複製する
         Backup()
       else
         #戻る処理
         Rollback()
       end
       JUDGE[:maru]=0
       JUDGE[:batu]=0
    end
    redirect_to("/game_start/#{session[:user_id]}")
  end
#確定
  def confirm

  end

  def rollback
    Rollback()
    page_update()
  end

  def page_update
    @player = Player.find_by(user_id: session[:user_id])
    @boards = Board.all.sort
    respond_to do |format|
      format.html
      format.js {render :page_update}
    end
  end

end
