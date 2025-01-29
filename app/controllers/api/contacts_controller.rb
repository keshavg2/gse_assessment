class Api::ContactsController < ApplicationController
    def resolve_contact
      email = params[:email]
      phone = params[:phone]
  
      return render json: { error: 'Email and phone are required' }, status: :bad_request unless email.present? && phone.present?
  
      # Find all matching contacts by email or phone
      matching_contacts = Contact.where("email = ? OR phone = ?", email, phone)
  
      if matching_contacts.empty?
        # No match found, create a new primary contact
        primary_contact = Contact.create!(email: email, phone: phone)
        return render json: format_response([primary_contact])
      end
  
      # Identify distinct primary contacts
      primary_contacts = matching_contacts.map { |c| c.primary || c }.uniq
      oldest_primary = primary_contacts.min_by(&:created_at)
  
      # **Step 1: Consolidate all contacts under the oldest primary**
      primary_contacts.each do |primary|
        next if primary == oldest_primary
  
        # Reassign secondary contacts
        primary.secondary_contacts.update_all(primary_id: oldest_primary.id)
        # Reassign the primary itself
        primary.update!(primary_id: oldest_primary.id)
      end
  
      # **Step 2: Add the new email and phone as a secondary contact if they don't already exist**
      all_related_contacts = oldest_primary.all_related_contacts
      unless all_related_contacts.exists?(email: email, phone: phone)
        Contact.create!(email: email, phone: phone, primary_id: oldest_primary.id)
      end
  
      # Fetch all updated contacts for the response
      all_related_contacts = oldest_primary.all_related_contacts
      render json: format_response(all_related_contacts)
    end
  
    private
  
    # Format response JSON
    def format_response(contacts)
      {
        contactIds: contacts.map(&:id).take(4),
        emails: contacts.pluck(:email).uniq,
        phones: contacts.pluck(:phone).uniq
      }
    end
end
