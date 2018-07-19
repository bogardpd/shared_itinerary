class AddCityToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :city, :string
  end
end
