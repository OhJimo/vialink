class AddUserAndExpirationToLinks < ActiveRecord::Migration[8.0]
  def change
    add_reference :links, :user, null: false, foreign_key: true
    add_column :links, :expires_at, :datetime
    add_column :links, :click_count, :integer, default: 0, null: false
    add_index :links, :expires_at
  end
end
