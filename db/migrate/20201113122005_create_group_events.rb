class CreateGroupEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :group_events do |t|
      t.date :start_on
      t.date :end_on
      t.integer :duration
      t.string :name
      t.text :description
      t.string :location
      t.boolean :deleted, default: false
      t.integer :status, null: false
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps
    end

    add_index :group_events, :id, unique: true
    add_index :group_events, [:user_id, :id], unique: true
  end
end
