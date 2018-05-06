class RemoveIsArrivalFromTravelers < ActiveRecord::Migration[5.2]
  def change
    remove_column :travelers, :is_arrival, :boolean
  end
end
