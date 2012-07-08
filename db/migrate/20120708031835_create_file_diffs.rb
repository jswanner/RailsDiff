class CreateFileDiffs < ActiveRecord::Migration
  def change
    create_table :file_diffs do |t|
      t.references :diff
      t.string :file_path
      t.text :text

      t.timestamps
    end
    add_index :file_diffs, :diff_id
  end
end
