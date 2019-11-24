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
     # 後で変更　更新しないように別枠で書く方がいい
     @number_of_decks = @deck.size
     @turn = Boardlog.find(1).turn
     #ターンプレイヤーのID （全てのプレイヤー ÷ ターン数 ＝ 余り）- あがりのプレイヤー
     @turn_player = Player.find_by(id: PLAYERS[:user_id][0])
     @boardlog_last = Boardlog.last
     respond_to do |format|
       format.html
       format.json {@new_log = Boardlog.where('id > ?',params[:logid])
                    @all_log = Boardlog.all
                    }
     end
  end

  def draw
      #場にカードが無ければ
      if params[:loglast_id].to_i == Boardlog.last.id
          deck = Deck.last
          @current_player.hand << deck.deck[0]
          @current_player.save
          deck.deck.slice!(0)
          deck.save
          #ホールドに再登録
          Backup()
          PLAYERS[:user_id].push(PLAYERS[:user_id].shift)
          #最終的にターンプレイヤが変わったらページを切り替える
          turn = Boardlog.find(1)
          turn.turn += 1
          turn.save
          redirect_to("/game_start/#{session[:user_id]}")
      else
        page_update()
      end


  end

  def action_step1
    @hand_number = (params[:position]).to_i
      if @current_player.word == nil
          @current_player.word, @current_player.position = params[:name], params[:position]
          @current_player.save
          respond_to do |format|
            format.html
            format.js
          end
     elsif
        #選択中の手札を交換する #(else) 選択中の手札を押すと戻る
        if @current_player.word != params[:name] && @current_player.position != params[:position]
          hand = @current_player.hand.split("")
          hand[(@current_player.position).to_i], hand[(params[:position]).to_i] = hand[(params[:position]).to_i], hand[(@current_player.position).to_i]
          @current_player.hand = hand.join("")
        end
          #同じ手札を押した時
          @current_player.word,@current_player.position = nil, nil
          @current_player.save
          page_update()
      end
  end

  def action_step2
      if  @current_player.word != nil && params[:word] == "　"
        borad = Board.find_by(height: (params[:height]).to_i+1)
        borad.width[(params[:width]).to_i] = @current_player.word
        borad.save

        @current_player.hand.slice!(@current_player.position.to_i)

        Boardlog.create(moji: @current_player.word,height: (params[:height]).to_i,width: (params[:width]).to_i)
        @current_player.word,@current_player.position = nil, nil
        @current_player.save
        page_update()
      end
        #redirect_to("/game_start/#{session[:user_id]}")
  end
  #集計
  def aggregate
      #改善:どちらかを押したら両方押せなくしたい  JUDGE
      params[:aggregate] == "●" ? JUDGE[:maru] += 1 : JUDGE[:batu] += 1
      #page_update()
      #topに戻りBoardlog.last.idを取得しないと判定時自動更新できない。
      redirect_to("/game_start/#{session[:user_id]}")
  end

  def judge
    if Player.all.size-1 <=  JUDGE[:maru] + JUDGE[:batu]
      @current_player.word,@current_player.position = nil, nil
      @current_player.save
       if  (Player.all.size)-1 <= JUDGE[:maru]
         #flash[:notice] = "成功"
         if Player.find_by(id: session[:user_id]).hand.size == 0
           PLAYERS[:user_id].shift
         else
           PLAYERS[:user_id].push(PLAYERS[:user_id].shift)
         end
         #次のターンの設定
         #ターンプレイヤーの入れ替え
         turn = Boardlog.find(1)
         turn.turn += 1
         turn.save
         # 仮のdbを複製する
         Backup()
         JUDGE[:maru],JUDGE[:batu] = 0,0
         redirect_to("/game_start/#{session[:user_id]}")
       else
         #戻る処理
         #flash[:notice] = "失敗"
         JUDGE[:maru],JUDGE[:batu] = 0,0
         rollback()
       end
    end
  end

  def rollback
    Rollback()
    @current_player = Player.find_by(id: session[:user_id])
    @current_player.word,@current_player.position = nil, nil
    @current_player.save
    #リロードすると合わなくなる
    Boardlog.where('id > ?',params[:loglast_id]).each{|i| i.delete}
    page_update()
  end

  def page_update
    @current_player = Player.find_by(id: session[:user_id])
    @boards = Board.all.sort
    respond_to do |format|
      format.html
      format.js {render :page_update}
    end
  end

end
