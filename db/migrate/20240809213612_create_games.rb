# frozen_string_literal: true

# 20240809213612
class CreateGames < ActiveRecord::Migration[7.1]
  def up
    create_table(:games) do |t|
      t.string(:status, null: false, default: Game.status_standing_by)
      t.index(
        :status,
        unique: true,
        where:
          <<-SQL.squish
            status IN
              ('#{Game.status_standing_by}', '#{Game.status_sweep_in_progress}')
          SQL
      )

      t.string(:type, null: false)
      t.datetime(:started_at)
      t.datetime(:ended_at, index: true)
      t.float(:score, index: true)

      t.timestamps
      t.index(:created_at)
    end

    connection.execute(<<~SQL.squish)
      CREATE OR REPLACE FUNCTION check_game_status() RETURNS TRIGGER AS $$
      BEGIN
        IF (
          NEW.status
          IN ('#{Game.status_standing_by}', '#{Game.status_sweep_in_progress}')
        ) THEN
          IF EXISTS (
            SELECT 1 FROM games
            WHERE status =
              CASE WHEN NEW.status = '#{Game.status_sweep_in_progress}'
              THEN '#{Game.status_standing_by}'
              ELSE '#{Game.status_sweep_in_progress}'
              END
            AND id != NEW.id
          ) THEN
            RAISE EXCEPTION
            'Key (status) IN (#{Game.status_standing_by}, #{Game.status_sweep_in_progress}) already exists';
          END IF;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER game_status_check
      BEFORE INSERT OR UPDATE ON games
      FOR EACH ROW EXECUTE FUNCTION check_game_status();
    SQL
  end

  def down
    drop_table(:games)

    connection.execute(<<~SQL.squish)
      DROP TRIGGER IF EXISTS game_status_check ON games;
      DROP FUNCTION IF EXISTS check_game_status();
    SQL
  end
end
