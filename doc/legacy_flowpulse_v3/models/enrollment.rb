# app/models/enrollment.rb
class Enrollment < ApplicationRecord
  belongs_to :service,  optional: true
  belongs_to :journey,  optional: true
  belongs_to :mycontact

  belongs_to :requested_by_lead,
             class_name: "Datacontact",
             optional: true
  belongs_to :invited_by_lead,
             class_name: "Datacontact",
             optional: true

  has_many :bookings, dependent: :nullify
  has_many :commitments
  has_many :payments, as: :payable, dependent: :nullify
  has_many :certificates, dependent: :destroy
  has_many :issued_certificates,
           class_name: "Certificate",
           foreign_key: :issued_by_enrollment_id,
           dependent: :nullify





  enum :status, {
    draft:               0,
    requested:           1, # il cliente chiede accesso
    pending_confirmation: 2, # serve azione del tutor/pro
    confirmed:           3, # enrollment attivo
    cancelled:           4,
    rejected:            5,
    completed:           6
  }

  enum :mode, {
    autonomia:  0,
    individuale: 1,
    gruppo:     2,
    lavoratore: 3 # es. chi eroga/produce
  }

  enum :request_kind, {
    diretto:   0, # creato dall'operatore/tutor
    invito:    1, # l'utente è invitato
    candidatura: 2 # l'utente fa richiesta autonoma
  }

   enum :phase, {
    problema: 0,
    obiettivo: 1,
    previsione: 2,
    responsabile_progettazione: 3,
    step_necessari: 4,
    impegno: 5,
    realizzazione: 6,
    test: 7,
    attivo: 8,
    chiuso: 9
  }, prefix: true

  def requester
    requested_by_lead || datacontact
  end

  def inviter
    invited_by_lead
  end

  def confirm!
    update!(status: :confirmed)
  end

  def cancel!
    update!(status: :cancelled)
  end

  def taxbranch
    service&.taxbranch || journey&.taxbranch
  end

  def domain
    taxbranch&.header_domain
  end
end
