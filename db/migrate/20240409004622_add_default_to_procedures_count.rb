class AddDefaultToProceduresCount < ActiveRecord::Migration[7.1]
  def change
    change_column :processors, :procedures_count, :integer, default: 0
  end
end
