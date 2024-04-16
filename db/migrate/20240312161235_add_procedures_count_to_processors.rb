class AddProceduresCountToProcessors < ActiveRecord::Migration[7.1]
  def change
    add_column :processors, :procedures_count, :integer
  end
end
