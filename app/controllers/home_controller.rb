class HomeController < ApplicationController
  before_action :players_zero,{except:[:top,:host_login_check,:host_login]}

  def top

  end

  def host_login
    @player = Player.new
  end

  def host_login_check
    if params[:password] ==  "2580"
        #前回のデータ削除
        WAIT[:set] = false
        WAIT[:player], WAIT[:join] = 0,0
        #DBを消さずにホストユーザーに紐付けると複数アプリが扱える。
        Player.all.each{|i| i.delete}
        Deck.all.each{|i| i.delete}
        Turn.all.each{|i| i.delete}
        @player = Player.new(name: params[:name])
        if @player.save
            #ホストプレイヤーが作られてから６０秒までゲストが参加できる。
            session[:user_id] = @player.id
            redirect_to("/setting")
        else
            render("host_login")
        end

    else
      flash.now[:notice] = "パスワードが違います。"
      render("top")
    end
  end

  def setting

  end

  def setting_player
    WAIT[:player] = (params[:player]).to_i
    WAIT[:join] = 1
    redirect_to("/wait_area")
  end

  def gerst_login
    @player = Player.new
    time = Time.now
    if  WAIT[:player] == 0
       flash[:notice] = "ホストがいません。"
       redirect_to("/")
    #ホストプレイヤーが作られて60秒後
    elsif Player.all.sort[0].created_at <= time - 60
        flash[:notice] = "タイムオーバーです。"
        redirect_to("/")
    elsif WAIT[:player] <= WAIT[:join]
       flash[:notice] = "人数オーバーです。"
       redirect_to("/")
    end
  end

  def gerst_login_check
        @player = Player.new(name: params[:name])
        if @player.save
          session[:user_id] = @player.id
          WAIT[:join] += 1
          redirect_to("/wait_area")
        else
          render("gerst_login")
        end
  end

  def wait_area
     @wait = "#{WAIT[:player]},#{WAIT[:join]}"
     @host_player = Player.all.sort[0]
     @WAIT = WAIT[:set]
  end

  def wait_area_check
    if  WAIT[:player] == WAIT[:join] && WAIT[:set] == true
      redirect_to("/game_start/#{session[:user_id]}")
    else
      render("wait_area")
    end
  end

  def board_set
    moji = MOJI[:moji]
    moji = moji.split("").shuffle.join
    @deck = Deck.create(deck: moji)
    Board.all.each{|i| i.delete }
    Boardlog.all.each{|i| i.delete }
    1.upto(6){|i|
      if i == 3
          Board.create(width:"　　　　　#{moji[0]}　　　　",height:i)
          Boardlog.create(id:1,height:2,width:5,moji: moji[0],turn: 0,confirm: true)
      elsif i == 4
          Board.create(width:"　　　　#{moji[1]}　　　　　",height:i)
          Boardlog.create(id:2,height:3,width:4,moji: moji[1],confirm: true)
      else
          Board.create(width:"　　　　　　　　　　",height:i)
      end
    }

    @deck.deck.slice!(0,2)
    Player.all.size.times{|i|
       player = Player.all.sort[i]
       player.hand = @deck.deck[0..9]
       player.save
       @deck.deck.slice!(0,10)
    }
    @deck.save

    PLAYERS[:user_id] = Player.all.map(&:id).shuffle!
    Turn.create(player: PLAYERS[:user_id].size.to_i,turn_player_id: PLAYERS[:user_id][0].to_i)
    # 仮のdbを複製する
    Backup()
    WAIT[:set] = true
    redirect_to("/wait_area")
  end
end
