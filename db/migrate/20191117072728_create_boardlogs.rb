class CreateBoardlogs < ActiveRecord::Migration[5.2]
  def change
    create_table :boardlogs do |t|
      t.string :moji
      t.integer :height
      t.integer :width
      t.integer :turn
      t.timestamps
    end
  end
end
