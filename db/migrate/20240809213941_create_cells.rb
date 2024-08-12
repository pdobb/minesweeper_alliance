class CreateCells < ActiveRecord::Migration[7.1]
  def change
    create_table :cells do |t|
      t.references :board, null: false, foreign_key: true
      t.jsonb :coordinates, null: false, default: {}
      t.string :value
      t.boolean :mine, null: false, default: false, index: true

      t.timestamps
    end

    add_index :cells, :coordinates, using: :gin
  end
end
