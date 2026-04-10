# app/models/booking.rb
class Booking < ApplicationRecord
  belongs_to :service,     optional: true
  belongs_to :eventdate
  belongs_to :mycontact
  belongs_to :enrollment,  optional: true
  belongs_to :commitment, optional: true

  belongs_to :requested_by_lead,
             class_name: "Datacontact",
             optional: true
  belongs_to :invited_by_lead,
             class_name: "Datacontact",
             optional: true

  has_many :payments, as: :payable, dependent: :nullify

  enum :status, {
    draft_booking:               0,
    requested:           1,
    pending_confirmation: 2,
    confirmed:           3,
    checked_in:          4,
    no_show:             5,
    cancelled:           6,
    completed:           7
  }


  enum :mode, {
    autonomia:  0,
    individuale: 1,
    gruppo:     2,
    lavoratore: 3
  }

  enum :participant_role, {
    utente:       0,
    professionista: 1,
    role_lavoratore:   2
  }

  def requester
    requested_by_lead || mycontact
  end

  def inviter
    invited_by_lead
  end

  def confirm!
    update!(status: :confirmed)
  end
end
