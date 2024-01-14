class AddCustomersCountToProcessors < ActiveRecord::Migration[7.1]
  def change
    add_column :processors, :customers_count, :integer, default: 0, null: false
  end
end
