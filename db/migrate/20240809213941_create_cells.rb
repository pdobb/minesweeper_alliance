class CreateCells < ActiveRecord::Migration[7.1]
  def change
    create_table :cells do |t|
      t.references :board, null: false, foreign_key: true
      t.integer :x
      t.integer :y
      t.string :value

      t.timestamps
    end
  end
end
