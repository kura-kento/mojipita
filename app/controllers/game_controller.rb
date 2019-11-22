class GameController < ApplicationController
  before_action :otherplayers,{only:[:draw,:action_step2,:judge]}
  before_action :turnplayer,{only:[:aggregate]}

  def top
     @deck = Deck.last.deck
     @boards = Board.all.sort
     @players= PLAYERS[:user_id].map{|user_id| Player.find_by(user_id: user_id) }

     # 後で変更　更新しないように別枠で書く方がいい
     @player = Player.find_by(user_id: session[:user_id])
     #@players_name.shuffle!

     @number_of_decks = @deck.size
     @turn = Boardlog.find(1).turn
     #ターンプレイヤーのID （全てのプレイヤー ÷ ターン数 ＝ 余り）- あがりのプレイヤー
     @turn_player = Player.all.sort[(Boardlog.find(1).turn % Player.all.size)]
     @player_name=Player.find_by(user_id: PLAYERS[:user_id][0])
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
          player = Player.find_by(user_id: session[:user_id])
          player.hand << deck.deck[0]
          player.save
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
    player = Player.find_by(user_id: session[:user_id])
    @hand_number = (params[:position]).to_i
      if player.word == nil
          player.word, player.position = params[:name], params[:position]
          player.save
          respond_to do |format|
            format.html
            format.js
          end
     else
        #選択中の手札を押すと戻る
        if player.word == params[:name]
        #選択中の手札を交換する
        else
            hand = player.hand.split("")
            hand[(player.position).to_i], hand[(params[:position]).to_i] = hand[(params[:position]).to_i], hand[(player.position).to_i]
            player.hand = hand.join("")
        end
        player.word,player.position = nil, nil
        player.save
        page_update()
      end

  end


  def action_step2
      player = Player.find_by(user_id: session[:user_id])
      if  player.word != nil && params[:action_step2] == "　"

        borad = Board.find_by(height: (params[:height]).to_i+1)
        borad.width[(params[:width]).to_i] = player.word
        borad.save

        player.hand.slice!(player.position.to_i)

        Boardlog.create(moji: player.word,height: (params[:height]).to_i,width: (params[:width]).to_i)

        player.word,player.position = nil, nil
        player.save
        page_update()
      end
        #redirect_to("/game_start/#{session[:user_id]}")
  end
  #集計
  def aggregate
      #改善:どちらかを押したら両方押せなくしたい  JUDGE
      params[:aggregate] == "●" ? JUDGE[:maru] += 1 : JUDGE[:batu] += 1
      redirect_to("/game_start/#{session[:user_id]}")
      # page_update()
  end

  def judge
    if Player.all.size-1 <=  JUDGE[:maru] + JUDGE[:batu]
       if  (Player.all.size)-1 <= JUDGE[:maru]
         #次のターンの設定
         #ターンプレイヤーの入れ替え
         PLAYERS[:user_id].push(PLAYERS[:user_id].shift)

         turn = Boardlog.find(1)
         turn.turn += 1
         turn.save
         # 仮のdbを複製する
         Backup()
         JUDGE[:maru],JUDGE[:batu] = 0,0
         redirect_to("/game_start/#{session[:user_id]}")
       else
         #戻る処理
         JUDGE[:maru],JUDGE[:batu] = 0,0
         rollback()
       end

    end



  end


  def rollback
    Rollback()
    player = Player.find_by(user_id: session[:user_id])
    player.word,player.position = nil, nil
    player.save
    #リロードすると合わなくなる
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
