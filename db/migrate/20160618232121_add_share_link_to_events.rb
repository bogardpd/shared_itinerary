class AddShareLinkToEvents < ActiveRecord::Migration
  def change
    add_column :events, :share_link, :string
  end
end
