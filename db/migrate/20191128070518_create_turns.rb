class CreateTurns < ActiveRecord::Migration[5.2]
  def change
    create_table :turns do |t|
      t.boolean :confirm, default:false
      t.integer :player
      t.integer :maru, default:0
      t.integer :batu, default:0
      t.integer :turn_player_id
      t.integer :count, default:1
      t.timestamps
    end
  end
end
