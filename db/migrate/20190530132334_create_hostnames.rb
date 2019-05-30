class CreateHostnames < ActiveRecord::Migration[5.2]
  def change
    create_table :hostnames do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :hostnames, :name, unique: true
  end
end
