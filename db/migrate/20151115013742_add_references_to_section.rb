class AddReferencesToSection < ActiveRecord::Migration[5.2]
  def change
    add_reference :sections, :event, index: true, foreign_key: true
  end
end
