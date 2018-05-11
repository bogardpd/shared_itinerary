class CreateAirlines < ActiveRecord::Migration[5.2]
  def change
    create_table :airlines do |t|
      t.string :iata_code
      t.string :name
    end
    add_index :airlines, :iata_code
  end
end
