class Contact < ApplicationRecord
  belongs_to :primary, class_name: 'Contact', optional: true
  has_many :secondary_contacts, class_name: 'Contact', foreign_key: 'primary_id'

  scope :find_by_email_or_phone, ->(email, phone) {
    where("email = ? OR phone = ?", email, phone)
  }

  def all_related_contacts
    Contact.where(primary_id: self.primary_id || self.id).or(Contact.where(id: self.id))
  end
end
