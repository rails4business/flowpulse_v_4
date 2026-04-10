# app/models/tag_positioning.rb
class TagPositioning < ApplicationRecord
  CATEGORIES = %w[
    problema
    target
    keyword
    messaggio
    servizio
    concorrente
    contenuto
  ].freeze


  belongs_to :taxbranch
  belongs_to :lead, optional: true
  belongs_to :post, optional: true # tienilo solo se esiste post_id

  validates :name, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  # Se vuoi evitare duplicati anche lato app (oltre all'indice DB)
  validates :name, uniqueness: { scope: [ :taxbranch_id, :category ] }

  scope :for_taxbranch, ->(tb) do
    tb_id = tb.respond_to?(:id) ? tb.id : tb
    where(taxbranch_id: tb_id)
  end

  scope :categories_for, ->(tb) do
    for_taxbranch(tb).distinct.order(:category).pluck(:category)
  end

  # Helpers per metadata (jsonb)
  def meta
    self.metadata ||= {}
  end

  def description
    meta["description"]
  end

  def description=(value)
    self.metadata = meta.merge("description" => value)
  end

  def rel
    meta["rel"] || {}
  end

  # Esempio: tag.related_ids("solves") => [1,2,3]
  def related_ids(key)
    Array(rel[key.to_s]).map(&:to_i).uniq
  end

  # Esempio: tag.related("solves") => ActiveRecord::Relation
  def related(key)
    self.class.where(id: related_ids(key))
  end
end
