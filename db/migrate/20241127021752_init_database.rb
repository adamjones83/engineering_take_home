class InitDatabase < ActiveRecord::Migration[7.2]
  def up
    # clients table
    create_table :clients do |t|
      t.string :name
      t.timestamps
    end

    # buildings table
    create_table :buildings do |t|
      t.references :client, null: false, foreign_key: true
      t.string :address
      t.string :state
      t.string :zip
      t.timestamps
    end

    # custom fields table
    create_table :custom_fields do |t|
      t.references :client, null: false, foreign_key: true
      t.string :name
      t.string :field_type
      t.timestamps
    end

    # custom field enum options (for enum field_type fields)
    create_table :custom_field_choices do |t|
      t.references :custom_field, null: false, foreign_key: true
      t.string :value
      t.timestamps
    end

    # building custom fields
    create_table :building_custom_fields do |t|
      t.references :custom_field, null: false, foreign_key: true
      t.references :building, null: false, foreign_key: true
      t.string :value
      t.timestamps
    end
  end

  def down
    drop_table :building_custom_fields
    drop_table :buildings
    drop_table :custom_field_choices
    drop_table :custom_fields
    drop_table :clients
  end
end
