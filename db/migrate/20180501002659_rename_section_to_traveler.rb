class RenameSectionToTraveler < ActiveRecord::Migration[5.2]
  def change
    rename_table :sections, :travelers
  end
end
