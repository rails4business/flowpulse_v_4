class PosturacorrettaController < ApplicationController
  layout "posts"
  layout false, only: [ :mappa, :aree, :ambiti, :medicina, :oriente_occidente ]
  before_action :set_post_context, only: :manifesto
  PAGE_META = {
    "contenuti" => {
      group: "Risorse",
      title: "Contenuti",
      description: "Approfondimenti pratici per comprendere il corpo e migliorare le scelte quotidiane."
    },
    "corsi_online" => {
      group: "Risorse",
      title: "Corsi online",
      description: "Percorsi guidati da seguire online per allenare consapevolezza, postura e fisiologia."
    },
    "manifesto" => {
      group: "Risorse",
      title: "Manifesto",
      description: "I principi che guidano l'Accademia PosturaCorretta e il suo approccio educativo."
    },
    "eventi" => {
      group: "Risorse",
      title: "Eventi",
      description: "Incontri e appuntamenti dedicati a educazione, salute e stile di vita."
    },
    "servizi" => {
      group: "Risorse",
      title: "Servizi",
      description: "Servizi e percorsi pratici per applicare nella vita quotidiana i principi di PosturaCorretta."
    },
    "rete" => {
      group: "Rete",
      title: "Rete",
      description: "Un unico punto di accesso alla rete: persone, ruoli, centri e metodiche."
    },
    "persone" => {
      group: "Rete",
      title: "Persone",
      description: "Un punto di accesso per orientarsi e costruire il proprio percorso nella rete."
    },
    "rete_professionale" => {
      group: "Rete",
      title: "Insegnanti",
      description: "Insegnanti, tutor e segreteria operativa della rete."
    },
    "centri" => {
      group: "Rete",
      title: "Centri",
      description: "Spazi e realtà territoriali dove formazione, servizi e continuità possono integrarsi."
    },
    "metodiche" => {
      group: "Rete",
      title: "Percorsi formativi",
      description: "Approcci, competenze e linguaggi diversi che dialogano su basi fisiologiche comuni."
    }
  }.freeze

  def contenuti
    set_page_meta
  end

  def corsi_online
    set_page_meta
  end

  def manifesto
    set_page_meta
  end

  def eventi
    set_page_meta
  end

  def servizi
    set_page_meta
  end

  def rete
    set_page_meta
  end

  def persone
    set_page_meta
  end

  def rete_professionale
    set_page_meta
  end

  def centri
    set_page_meta
  end

  def metodiche
    set_page_meta
  end

  def mappa
  end

  def aree
  end

  def ambiti
  end

  def medicina
  end

  def oriente_occidente
  end

  private

  def set_page_meta
    meta = PAGE_META.fetch(action_name)
    @page_group = meta[:group]
    @page_title = meta[:title]
    @page_description = meta[:description]
  end

  def set_post_context
    domain_taxbranch = Current.domain&.taxbranch
    candidate = domain_taxbranch&.post

    @post =
      if candidate && post_published_for_public?(candidate)
        candidate
      else
        Post.joins(:taxbranch)
            .where(
              taxbranches: {
                status: Taxbranch.statuses[:published],
                visibility: Taxbranch.visibilities[:public_node]
              }
            )
            .where("taxbranches.published_at IS NULL OR taxbranches.published_at <= ?", Time.current)
            .order(Arel.sql("COALESCE(taxbranches.published_at, taxbranches.created_at) DESC"))
            .first
      end
  end

  def post_published_for_public?(post)
    tb = post.taxbranch
    return false unless tb
    return false unless tb.published?
    return false unless tb.public_node?
    return false if tb.published_at.present? && tb.published_at > Time.current

    true
  end
end
