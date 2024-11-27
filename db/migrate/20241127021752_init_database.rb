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
      t.string :type
      t.timestamps
    end

    # building custom fields
    create_table :building_custom_fields do |t|
      t.references :client, null: false, foreign_key: true
      t.references :building, null: false, foreign_key: true
      t.string :value
      t.timestamps
    end

    # Also add some sample data
    Client.create(name: 'client1')
    Client.create(name: 'client2')
    Client.create(name: 'client3')
    Client.create(name: 'client4')
    Client.create(name: 'client5')
  end

  def down
    drop_table :building_custom_fields
    drop_table :buildings
    drop_table :custom_fields
    drop_table :clients
  end
end
