class AddIndexToAirlines < ActiveRecord::Migration
  def change    
    remove_index :airlines, :iata_code
    add_index :airlines, :iata_code, :unique => true
  end
end
