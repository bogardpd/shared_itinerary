class RenameFlightsSectionIdToTravelerId < ActiveRecord::Migration[5.2]
  def change
    rename_column :flights, :section_id, :traveler_id
  end
end
