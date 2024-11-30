class AddSampleData < ActiveRecord::Migration[7.2]
  def up
    (1..5).each { |num| generate_sample_client_data("client #{num}") }
  end

  def down
    # wipe the data - WARNING: very dangerous once real data exists!
    BuildingCustomField.all.delete_all
    Building.all.delete_all
    CustomFieldChoice.all.delete_all
    CustomField.all.delete_all
    Client.all.delete_all
  end

  def generate_sample_client_data(name)
    styles= ['Cape Cod', 'Craftsman', 'Ranch', 'Mid-century Modern', 'Tudor Revival', 'Farmhouse', 'Greek Revival', 'Georgian', 'Cabin', 'Colonial Revival', 'Cottage', 'Other']
    categories = ['Single Family', 'Multi-family', 'Apartment', 'Condo', 'Duplex', 'Commercial', 'Mobile Home', 'Land', 'Other']
    custom_fields = [
      { name: 'Square Feet', field_type: 'number', generate_value: Proc.new { Random.rand(16..30) * 100 } },
      { name: 'Bedrooms', field_type: 'number', generate_value: Proc.new { Random.rand(1..5) } },
      { name: 'Bathrooms', field_type: 'number', generate_value: Proc.new { Random.rand(1..3) } },
      { name: 'Year Constructed', field_type: 'number', generate_value: Proc.new { Random.rand(1920..2015) } },
      { name: 'Lot Size (sqft)', field_type: 'number', generate_value: Proc.new { Random.rand(6000..20000)} },
      { name: 'Style', field_type: 'enum', choices: styles, generate_value: Proc.new { styles.sample } },
      { name: 'Category', field_type: 'enum', choices: categories, generate_value: Proc.new { categories.sample } },
      { name: 'Notes', field_type: 'freeform', generate_value: Proc.new { '-' } },
      { name: 'Description', field_type: 'freeform', generate_value: Proc.new { '(none)' } },
      { name: 'Ref #', field_type: 'freeform', generate_value: Proc.new { Random.rand(10000..900000).to_s } }
    ]
    streets = ['Wells Branch Pkwy','Cesar Chavez St','Guadalupe St','Main St','Circletree Loop','Chestnut Path','Creekwood Pl','Gibson St','James St','Sunningdale St','Taylor St','Sycamore St','Logan St','Candace Loop','Wells Point Pass','Little Elm Park','Summit Pass']

    # pick 2-5 custom fields to associate with this client
    field_count = Random.rand(2..5)
    client_fields = custom_fields.sample(field_count)

    # generate 20-50 randomized buildings with fake custom field data for the client's custom fields
    buildings = (20..50).map do
      street_num = Random.rand(100..9999)
      {
        address: "#{street_num} #{streets.sample}",
        state: 'TX',
        zip: Random.rand(78701..78799)
      }
    end

    # insert the client
    client = Client.create(name:)
    
    # insert some custom fields for the client and field choices for any enum type fields
    field_ids = client_fields.map do |field| 
      cf = CustomField.create(client_id: client.id, name: field[:name], field_type: field[:field_type])
      if field[:field_type] == 'enum'
        field[:choices].each { |value| CustomFieldChoice.create(custom_field_id: cf.id, value:) }
      end
      [cf.id, field[:name], field[:generate_value]]
    end

    # insert the sample buildings along with generated values for this client's custom fields
    buildings.each do |building|
      b = Building.create(client_id: client.id, **building)
      puts "== Building #{b.id} - #{building[:address]}"
      field_ids.each do |field_id, field_name, generate_value|
        value = generate_value.call
        puts "Field #{field_id} (#{field_name}): #{value}"
        BuildingCustomField.create(custom_field_id: field_id, building_id: b.id, value:)
      end
    end
  end
end
