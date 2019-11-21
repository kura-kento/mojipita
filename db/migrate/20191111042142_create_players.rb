class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.text :name
      t.text :hand
      t.integer :user_id
      t.string :word
      t.string :position
      t.timestamps
    end
  end
end
