class CreateDeckHolds < ActiveRecord::Migration[5.2]
  def change
    create_table :deck_holds do |t|
      t.text :deck

      t.timestamps
    end
  end
end
