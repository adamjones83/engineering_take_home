class Client < ApplicationRecord
  has_many :custom_fields
  has_many :buildings
end