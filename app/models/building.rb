class Building < ApplicationRecord
  belongs_to :client
  has_many :building_custom_fields
end