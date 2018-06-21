class AddContactInfoToTravelers < ActiveRecord::Migration[5.2]
  def change
    add_column :travelers, :contact_info, :string
  end
end
