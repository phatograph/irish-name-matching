class CreateLookupTableRecords < ActiveRecord::Migration
  def change
    create_table :lookup_table_records do |t|
      t.string :name
      t.integer :ref

      t.timestamps null: false
    end
  end
end
