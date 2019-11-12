class ApplicationController < ActionController::Base
  WAIT = {player: 0,join: 0}
  MOJI = {moji: 'あいいいいううううえおかかききくくけここささしししすすせそたたちちつつてととなにぬねのはひふへほまみむめもやゆゆよららりりるるれろわんんんんーー'}
  HAND_ACTION = {name: false,position: false}
  BOARD_ACTION = {name: false,position: false}
  HOLD ={id: false}
  TURN = {count: 0}
  JUDGE={maru: 0,batu:0}
end
