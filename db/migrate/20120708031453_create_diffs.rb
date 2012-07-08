class CreateDiffs < ActiveRecord::Migration
  def change
    create_table :diffs do |t|
      t.string :source
      t.string :target

      t.timestamps
    end
    add_index :diffs, :source
    add_index :diffs, :target
  end
end
