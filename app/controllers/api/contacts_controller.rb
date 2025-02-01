class Api::ContactsController < ApplicationController
  def resolve_contact
    email = params[:email]
    phone = params[:phone]

    return render json: { error: "Email and phone are required" }, status: :unprocessable_entity unless email.present? && phone.present?

    # Find contacts by email or phone
    matching_contacts = Contact.where("email = ? OR phone = ?", email, phone)

    puts matching_contacts.to_json

    if matching_contacts.exists?
      # Get all primary contacts from the matched records
      primary_contacts = matching_contacts.map { |c| c.primary_contact || c }.uniq

      # puts primary_contacts.to_json
      if primary_contacts.size > 1
        # If more than one primary contact exists, merge under the oldest primary
        primary_contact = primary_contacts.min_by(&:created_at)
        other_primary_contacts = primary_contacts - [primary_contact]

        other_primary_contacts.each do |secondary|
          secondary.update(primary_contact_id: primary_contact.id)  # Convert to secondary contact
        end
      else
        # Only one primary exists, so use it
        primary_contact = primary_contacts.first || matching_contacts.first
      end

      secondary_contacts = Contact.where(primary_contact_id: matching_contacts)

      puts secondary_contacts.to_json

      # Collect all related contacts (primary + secondary)
      # all_contacts = secondary_contacts + [primary_contact]
      puts primary_contacts.to_json

      # Collect all unique emails, phones, and contact IDs
      all_emails = (matching_contacts + primary_contacts + secondary_contacts).map(&:email).uniq
      all_phones = (matching_contacts + primary_contacts + secondary_contacts).map(&:phone).uniq
      contact_ids = (matching_contacts + primary_contacts + secondary_contacts).map(&:id).uniq

      puts matching_contacts.size
      if primary_contacts.size == 1 && matching_contacts.size <=1
      # If new details are introduced, create a secondary contact
        unless all_emails.include?(email) && all_phones.include?(phone)
          new_contact = Contact.create(email: email, phone: phone, primary_contact_id: primary_contact.id)
          contact_ids << new_contact.id
          all_emails << new_contact.email
          all_phones << new_contact.phone
        end
      end
    else
      # Create a new primary contact if no match exists
      primary_contact = Contact.create(email: email, phone: phone)
      contact_ids = [primary_contact.id]
      all_emails = [primary_contact.email]
      all_phones = [primary_contact.phone]
    end

    render json: {
      contactIds: contact_ids,
      emails: all_emails.uniq,
      phones: all_phones.uniq
    }
  end
end
