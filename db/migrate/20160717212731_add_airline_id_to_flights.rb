class AddAirlineIdToFlights < ActiveRecord::Migration[5.2]
  def change
    add_column :flights, :airline_id, :integer
  end
end
