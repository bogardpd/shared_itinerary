class AddShareLinkToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :share_link, :string
  end
end
