class CreateRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :roles do |t|
      t.string :nombre, null: false
      t.string :slug, null: false
      t.boolean :active, default: true
      
      t.timestamps
    end
  end
end
