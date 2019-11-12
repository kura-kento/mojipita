class CreatePlayerHolds < ActiveRecord::Migration[5.2]
  def change
    create_table :player_holds do |t|
      t.text :name
      t.text :hand
      t.integer :user_id
      t.timestamps
    end
  end
end
