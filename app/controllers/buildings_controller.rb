class BuildingsController < ApplicationController
  include Pagination
  skip_before_action :verify_authenticity_token

  # GET /buildings
  def index
    @query = Building.all.order(:id)
    @paged = @query.limit(page_size).offset(paginate_offset)
    total = Building.count
    pages = (total / page_size) + (total % page_size == 0 ? 0 : 1)
    data = @paged.map do |building|
      field_values = building.building_custom_fields.to_h { |bcf| [bcf.custom_field_id, bcf.value] }
      building_field_values = building.client.custom_fields
        .sort_by { |cf| cf.name }
        .reject { |cf| ['id', 'client_name', 'address'].include?(cf.name) } # prevent overwriting reserved fields with bad custom field names
        .to_h { |cf| [cf.name, field_values[cf.id]] }
      
      {
        id: building.id,
        client_name: building.client.name,
        address: building.address,
        state: building.state,
        zip: building.zip,
        **building_field_values
      }
    end
    render json: { status: 'success', buildings: data, page: page_no, page_size:, total:, pages: }
  end

  # POST /buildings
  def create
    building, fields = parse_body

    # validate custom field values based on the field_type
    validate_custom_fields(fields)

    building = Building.create(**building)
    fields.each do |field|
      building.building_custom_fields.create(custom_field_id: field[:custom_field_id], value: field[:value])
    end

    render json: { success: true, data: serialize_building(building) }
  rescue => error
    render json: { success: false, error: }
  end

  # PUT /buildings/:id
  def update
    id = params[:id]
    building = Building.find(id)
    raise "building not found" if building.nil?

    new_building, fields = parse_body
    raise "clients for new and existing building do not match" unless building.client_id == new_building[:client_id]
    
    # validate custom field values based on the field_type
    validate_custom_fields(fields)

    # update the building
    building.address = new_building[:address]
    building.state = new_building[:state]
    building.zip = new_building[:zip]
    building.save!

    # delete existing custom field values and save the newly provided field values
    BuildingCustomField.where(building_id: id).destroy_all
    fields.each do |field|
      building.building_custom_fields.create(custom_field_id: field[:custom_field_id], value: field[:value])
    end

    render json: { success: true, data: serialize_building(building) }
  rescue => error
    render json: { success: false, error: }
  end

  private
  
  def parse_body
    data = JSON.parse(request.raw_post)
    raise "bad request - invalid JSON" unless data.instance_of?(Hash)

    client = client = Client.find_by(name: data['client_name'])
    raise "bad request - client missing or invalid" if client.nil?
    
    field_names = client.custom_fields.map { |cf| cf.name }
    valid_fields = ['client_name', 'address', 'state', 'zip', *field_names]
    
    # throw if any unrecognized/invalid key was included in the request
    invalid_keys = data.keys.reject { |key| valid_fields.include?(key) }
    raise "unrecognized field(s) #{invalid_keys.join(', ')}" unless invalid_keys.empty?
    
    # hashes of the data for the building & custom fields to be saved
    building = {
      client_id: client.id,
      address: data['address'],
      state: data['state'],
      zip: data['zip']
    }
    fields = client.custom_fields.map do |cf|
      {
        custom_field_id: cf.id,
        name: cf.name,
        field_type: cf.field_type,
        choices: cf.custom_field_choices.map { |cfc| cfc.value },
        value: data[cf.name]
      }
    end
    
    [building, fields]
  end

  def validate_custom_fields(fields)
    # validate field values by field type
    fields.each do |field|
      if field[:field_type] == 'number'
        raise "invalid value for #{field[:name]}, expecting number" if field[:value].present? && Float(field[:value], exception: false).nil?  
      elsif field[:field_type] == 'enum'
        raise "invalid value for #{field[:name]}" unless field[:value].nil? || field[:choices].include?(field[:value])
      end
    end
  end

  def serialize_building(building)
    field_values = building.building_custom_fields.to_h { |bcf| [bcf.custom_field_id, bcf.value] }
    building_field_values = building.client.custom_fields
      .sort_by { |cf| cf.name }
      .reject { |cf| ['id', 'client_name', 'address'].include?(cf.name) } # prevent overwriting reserved fields with bad custom field names
      .to_h { |cf| [cf.name, field_values[cf.id]] }
    
    {
      id: building.id,
      client_name: building.client.name,
      address: building.address,
      state: building.state,
      zip: building.zip,
      **building_field_values
    }
  end
end
