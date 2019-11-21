class HomeController < ApplicationController
  def top
  end

  def wait_area
     @wait= "#{WAIT[:player]},#{WAIT[:join]}"
  end

  def wait_area_check
    if  WAIT[:player] == WAIT[:join]
      redirect_to("/game_start/#{session[:user_id]}")
    else
      render("wait_area")
    end
  end

  def host_login

  end

  def host_login_check
    if params[:password] ==  "2580"
      session[:user_id] = 0
      WAIT[:player], WAIT[:join], JUDGE[:maru], JUDGE[:batu] = 0,0,0,0
      
      BOARD_ACTION[:name],BOARD_ACTION[:position] = false,false

      Player.all.each{|i| i.delete}
      Deck.all.each{|i| i.delete}
      Player.create(name: params[:name],user_id: session[:user_id])
      redirect_to("/setting")
    else
      render("host_login")
    end
  end
  def setting
  end

  def setting_player
    WAIT[:player] += (params[:player]).to_i
    WAIT[:join] += 1
    redirect_to("/wait_area")
  end

  def gerst_login
    player = Player.new(name: params[:name])
    if player.save
      session[:user_id] = player.id
      player.user_id = player.id
      player.save
      WAIT[:join] += 1
      redirect_to("/wait_area")
    else
      render("top")
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
          Boardlog.create(id:1,height:2,width:5,moji: moji[0],turn: 0)
      elsif i == 4
          Board.create(width:"　　　　#{moji[1]}　　　　　",height:i)
          Boardlog.create(id:2,height:3,width:4,moji: moji[1])
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

    PLAYERS[:user_id] = Player.all.map(&:user_id).shuffle!

    # 仮のdbを複製する
    Backup()
  #  DeckHold.all.each{|i| i.delete}
  #  DeckHold.create(deck:Deck.last.deck)
  end
end
