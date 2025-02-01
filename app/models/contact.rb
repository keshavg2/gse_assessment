class Contact < ApplicationRecord
  belongs_to :primary_contact, class_name: 'Contact', optional: true
  has_many :linked_contacts, class_name: 'Contact', foreign_key: 'primary_contact_id'
end
