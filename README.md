# Perchwell Engineering Take-Home

Welcome to the Perchwell take-home assignment!

# Requirements

Please see the requirements [here](https://github.com/RivingtonHoldings/engineering_take_home/blob/main/REQUIREMENTS.md).

## API Endpoints
- GET /buildings
  - get a paged response with all buildings
  - paging with query parameters 'page' and 'page_size', default page size is 25
- POST /buildings
  - expects an object with { client_name, address, state, zip }
  - allows setting custom fields via attributes matching the field name, values are blank if omitted
  - custom field values for field_type "number" must be a number or numeric string
  - custom field values for field_type "enum" must match a defined enum value
  - performs some basic validation and returns error response if invalid
- PUT /buildings/:id
  - works the same as the POST method but overwrites the building for the given building id
  - if client_name doesn't match the client of the existing building a validation error is thrown

See examples in `sample.http`

## Tables
- clients
- custom_fields
- custom_field_choices
  - the available choices for enum type custom fields
- buildings
- building_custom_fields
  - custom field values for buildings, by building id & custom field id

## Helpful SQL Queries

```SQL
-- View all the clients witht their custom fields & field choices (for enum type)
select c.name client, cf.name field, cf.field_type, cc.value
from clients c
left join custom_fields cf on c.id = cf.client_id
left join custom_field_choices cc on cf.id = cc.custom_field_id;

-- View all the buildings for a client, along with custom field values
select c.name, b.address, b.state, b.zip,
	array_agg(concat(cf.name, ': ', bcf.value)) fields
from buildings b
join clients c on c.id = b.client_id
left join custom_fields cf on cf.client_id = c.id
left join building_custom_fields bcf on bcf.building_id = b.id and bcf.custom_field_id = cf.id
where c.name = 'client 1'
group by b.id, c.id;
```
