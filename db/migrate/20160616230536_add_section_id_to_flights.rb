class AddSectionIdToFlights < ActiveRecord::Migration
  def change
    add_column :flights, :section_id, :integer
  end
end
