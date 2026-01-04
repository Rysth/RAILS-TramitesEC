class CreateCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :courses, :name, unique: true
  end
end
