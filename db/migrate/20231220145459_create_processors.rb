class CreateProcessors < ActiveRecord::Migration[7.1]
  def change
    create_table :processors do |t|
      t.string :code, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_reference :processors, :user, foreign_key: true
  end
end
