class CustomField < ApplicationRecord
  belongs_to :client
  has_many :custom_field_choices
end