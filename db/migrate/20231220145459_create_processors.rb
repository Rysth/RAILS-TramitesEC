class CreateProcessors < ActiveRecord::Migration[7.1]
  def change
    create_table :processors do |t|
      t.string :cedula, null: false
      t.string :nombres, null: false
      t.string :apellidos, null: false
      t.string :celular, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_reference :processors, :user, foreign_key: true
  end
end
