class AddSectionIdToFlights < ActiveRecord::Migration[5.2]
  def change
    add_column :flights, :section_id, :integer
  end
end
