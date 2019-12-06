class GameController < ApplicationController
  before_action :set_current_player
  before_action :otherplayers,{only:[:draw,:action_step2,:judge]}
  before_action :turnplayer,{only:[:aggregate]}
  before_action :players_zero
  before_action :session_id,{only:[:top]}

  def top
     @deck = Deck.last.deck
     @boards = Board.all.sort
     @players= Player.all.sort

     @number_of_decks = @deck.size
     @turn = Turn.last.count

     @turn_player = Player.find_by(id: PLAYERS[:user_id][0])
     @boardlogs = Boardlog.where(confirm:true)
     respond_to do |format|
         format.html
         if params[:path] == "000"
         format.json {@new_log = Boardlog.where(confirm:false)
                      @all_log = Boardlog.all
                      }
         else
         format.json {@turn_last = Turn.last}
         end
     end
  end

  def draw
      #場にカードが無ければ
      if Boardlog.where(confirm:false).size == 0
          deck = Deck.last
          @current_player.hand << deck.deck[0]
          @current_player.save
          deck.deck.slice!(0)
          deck.save
          #ホールドに再登録
          Backup()
          PLAYERS[:user_id].push(PLAYERS[:user_id].shift)
          #最終的にターンプレイヤが変わったらページを切り替える
          Turn.create(turn_player_id: PLAYERS[:user_id][0] ,player: Turn.last.player,count: Turn.last.count+1)

          redirect_to("/game_start/#{session[:user_id]}")
      else
        page_update()
      end


  end

  def action_step1
      if @current_player.word == nil
          @hand_number = (params[:position]).to_i
          @current_player.word, @current_player.position = params[:name], params[:position]
          @current_player.save
          respond_to do |format|
            format.js
          end
     else
        #選択中の手札を交換する #(else) 選択中の手札を押すと戻る
        if @current_player.position != params[:position]
          hand = @current_player.hand
          hand[(@current_player.position).to_i], hand[(params[:position]).to_i] = hand[(params[:position]).to_i], hand[(@current_player.position).to_i]
          @current_player.hand = hand
        end
          #同じ手札を押した時
          @current_player.word,@current_player.position = nil, nil
          @current_player.save
          page_update()
      end
  end

  def action_step2
      if  @current_player.word != nil && params[:word] == "　" && Turn.last.confirm == false
          borad = Board.find_by(height: (params[:height]).to_i+1)
          borad.width[(params[:width]).to_i] = @current_player.word
          borad.save
          @current_player.hand.slice!(@current_player.position.to_i)
          Boardlog.create(moji: @current_player.word, height: (params[:height]).to_i, width: (params[:width]).to_i)
          @current_player.word,@current_player.position = nil, nil
          @current_player.save
          @boards = Board.all.sort

          respond_to do |format|
            format.js
          end
      else
        @hand_number = @current_player.position
        @current_player = Player.find_by(id: session[:user_id])
        @boards = Board.all.sort
        respond_to do |format|
          format.js {render :page_update}
        end
      end
  end
      #確定
  def confirm
      turn = Turn.last
      turn.confirm = true
      turn.save
      @current_player.word,@current_player.position = nil, nil
      @current_player.save
      respond_to do |format|
        format.js
      end
  end
      #集計
  def aggregate
      turn = Turn.last
      params[:aggregate] == "●" ? turn.maru += 1 :turn.batu += 1
      turn.save
      respond_to do |format|
        format.js
      end
  end
      #判定
  def judge
    turn = Turn.last
    if turn.player-1 <=  turn.maru + turn.batu
       if  turn.player-1 <= turn.maru
         flash[:notice] = "成功"
         if Player.find_by(id: session[:user_id]).hand.size == 0
           PLAYERS[:user_id].shift
         else
           PLAYERS[:user_id].push(PLAYERS[:user_id].shift)
         end
         #次のターンの設定
         #ターンプレイヤーの入れ替え
         Boardlog.where(confirm:false).each{|i|
                                              i.confirm = true
                                              i.save
                                            }
         Turn.create(turn_player_id: PLAYERS[:user_id][0] ,player: Turn.last.player,count: Turn.last.count+1)
         # 仮のdbを複製する
         Backup()
         redirect_to("/game_start/#{session[:user_id]}")
       else
         #戻る処理
         flash.now[:notice] = "失敗"
         turn.confirm = false
         turn.maru,turn.batu =0,0
         turn.save
         rollback()
       end
    end
  end

  def rollback
    if Turn.last.confirm == false
      Rollback()
      @current_player = Player.find_by(id: session[:user_id])
      @current_player.word,@current_player.position = nil, nil
      @current_player.save
      Boardlog.where(confirm:false).each{|i| i.delete}
    end
    @current_player = Player.find_by(id: session[:user_id])
    @boards = Board.all.sort
    respond_to do |format|
      format.js {render :rollback}
    end
  end

  def page_update
    @current_player = Player.find_by(id: session[:user_id])
    @boards = Board.all.sort
    respond_to do |format|
      format.js {render :page_update}
    end
  end

end
