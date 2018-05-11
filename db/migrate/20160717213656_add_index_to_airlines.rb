class AddIndexToAirlines < ActiveRecord::Migration[5.2]
  def change    
    remove_index :airlines, :iata_code
    add_index :airlines, :iata_code, :unique => true
  end
end
