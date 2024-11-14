# frozen_string_literal: true

# Version: 20240912030247
class CreateCellTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table(:cell_transactions) do |t|
      t.string(:type, null: false, index: true)
      t.references(
        :user, type: :uuid, foreign_key: { on_delete: :nullify }, index: true)
      t.references(
        :cell, null: false, foreign_key: { on_delete: :cascade })
      t.text(:audit, null: false)

      t.datetime(:created_at, null: false, index: true)
    end

    add_index(
      :cell_transactions,
      %i[cell_id type],
      unique: true,
      where: "(type IN ('CellChordTransaction', 'CellRevealTransaction'))")
  end
end
