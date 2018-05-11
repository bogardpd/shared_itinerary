class RemoveIataCodesFromFlights < ActiveRecord::Migration[5.2]
  def change
    remove_column :flights, :airline_iata, :string
    remove_column :flights, :departure_airport_iata, :string
    remove_column :flights, :arrival_airport_iata, :string
  end
end
