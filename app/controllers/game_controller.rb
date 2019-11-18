class GameController < ApplicationController
  before_action :otherplayers,{only:[:draw,:action_step1,:judge]}
  before_action :turnplayer,{only:[:aggregate]}

  def top
     @deck = Deck.last.deck
     @boards = Board.all.sort
     @players_name=[]
     Player.all.size.times{|i|
        @players_name << [Player.all[i].name,Player.all[i].hand]
     }
     # 後で変更　更新しないように別枠で書く方がいい
     @player = Player.find_by(user_id: session[:user_id])
     #@players_name.shuffle!

     @number_of_decks = @deck.size
     @turn = TURN[:count]
     #ターンプレイヤーのID
     @player_id = Player.all.sort[(TURN[:count] % Player.all.size)].user_id

     @boardlog_last = Boardlog.last
     respond_to do |format|
       format.html
       format.json {@new_log = Boardlog.where('id > ?',params[:logid]) }
     end
  end

  def draw
      if params[:loglast_id].to_i == Boardlog.last.id
          deck = Deck.last
          player = Player.find_by(user_id: session[:user_id])
          player.hand << deck.deck[0]
          player.save
          deck.deck.slice!(0)
          deck.save
          #ホールドに再登録
          Backup()
          TURN[:count] += 1
      end
      redirect_to("/game_start/#{session[:user_id]}")
  end

  def action_step1
      @boards = Board.all.sort
      if HAND_ACTION[:name] == false
        HAND_ACTION[:name] = params[:action_step1]
        HAND_ACTION[:position] = (params[:hand]).to_i
        @hand_number = (params[:hand]).to_i
      #選択中の手札を押すと戻る
      elsif HAND_ACTION[:name] == params[:action_step1]
        HAND_ACTION[:name] = false
        HAND_ACTION[:position]= false
        @hand_number = (params[:hand]).to_i
      end
      respond_to do |format|
        format.html
        format.js
      end
      #redirect_to("/game_start/#{session[:user_id]}")
  end

  def action_step2

      if HAND_ACTION[:name] != false && params[:action_step2] == "　"

        borad = Board.find_by(height: (params[:height]).to_i+1)
        borad.width[(params[:width]).to_i] = HAND_ACTION[:name]
        borad.save

        player = Player.find_by(user_id: session[:user_id])
        player.hand.slice!(HAND_ACTION[:position])
        player.save

        Boardlog.create(moji: HAND_ACTION[:name],height: (params[:height]).to_i,width: (params[:width]).to_i)

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
      #改善:どちらかを押したら両方押せなくしたい
      params[:aggregate] == "●" ? JUDGE[:maru] += 1 : JUDGE[:batu] += 1
      page_update()
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


  def rollback
    Rollback()
    HAND_ACTION[:name] = false
    HAND_ACTION[:position]= false
    Boardlog.where('id > ?',params[:loglast_id]).each{|i| i.delete}
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
