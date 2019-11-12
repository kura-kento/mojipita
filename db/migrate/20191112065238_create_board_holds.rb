class CreateBoardHolds < ActiveRecord::Migration[5.2]
  def change
    create_table :board_holds do |t|
      t.string :width ,limit: 10
      t.integer :height

      t.timestamps
    end
  end
end
