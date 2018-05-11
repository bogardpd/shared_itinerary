class CreateAirports < ActiveRecord::Migration[5.2]
  def change
    create_table :airports do |t|
      t.string :iata_code
      t.string :name
      t.timestamps null: false
    end
    
    add_index :airports, :iata_code, :unique => true
  end
end
