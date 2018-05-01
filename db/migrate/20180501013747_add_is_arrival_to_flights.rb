class AddIsArrivalToFlights < ActiveRecord::Migration[5.2]
  def change
    add_column :flights, :is_arrival, :boolean
  end
end
