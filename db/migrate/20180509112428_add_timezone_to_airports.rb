class AddTimezoneToAirports < ActiveRecord::Migration[5.2]
  def change
    add_column :airports, :timezone, :string
  end
end
