# app/models/payment.rb
class Payment < ApplicationRecord
  belongs_to :contact
  belongs_to :payable, polymorphic: true

  belongs_to :parent_payment,
             class_name: "Payment",
             optional: true
  has_many   :child_payments,
             class_name: "Payment",
             foreign_key: :parent_payment_id,
             dependent: :nullify

  enum :method, {
    cash:          0,
    bank_transfer: 1,
    card_pos:      2,
    paypal:        3,
    dash:          4
  }

  enum :status, {
    pending:            0,
    authorized:         1,
    paid:               2,
    failed:             3,
    refunded:           4,
    partially_refunded: 5
  }

  enum :kind, {
    charge:   0,
    refund:   1,
    adjust:   2
  }
end
