class CreateAirlines < ActiveRecord::Migration
  def change
    create_table :airlines do |t|
      t.string :iata_code
      t.string :name
    end
    add_index :airlines, :iata_code
  end
end
