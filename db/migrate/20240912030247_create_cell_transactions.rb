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

      t.datetime(:created_at, null: false, index: true)
    end

    CellTransaction.reset_column_information

    add_index(
      :cell_transactions,
      %i[cell_id type],
      unique: true,
      where:
        CellTransaction.arel_table[:type].in(CellTransaction::UNIQUE_TYPES)
          .to_sql)
  end
end
