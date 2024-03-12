class UpdateProceduresCountForCustomers < ActiveRecord::Migration[7.1]
  def up
    Customer.find_each do |customer|
      count = customer.procedures.count
      customer.update_columns(procedures_count: count)
    end
  end
end
