class AddIcaoCodeToAirlinesAndAirports < ActiveRecord::Migration[5.2]
  def change
    add_column :airlines, :icao_code, :string
    add_column :airports, :icao_code, :string
    remove_index :airlines, :iata_code
    remove_index :airports, :iata_code
  end
end
