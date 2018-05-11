class AddNoteToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :note, :text
  end
end
