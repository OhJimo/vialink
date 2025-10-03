class CreateLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :links do |t|
      t.string :original_url, null: false
      t.string :code, null: false
      t.string :cta_text
      t.string :cta_link
      t.string :cta_button_text
      t.string :cta_position
      t.string :cta_color

      t.timestamps
    end

    add_index :links, :code, unique: true
  end
end
