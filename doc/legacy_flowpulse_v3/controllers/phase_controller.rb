class PhaseController < ApplicationController
  before_action :set_taxbranch

  def problema
    load_phase(:problema)
  end

  def obiettivo
    load_phase(:obiettivo)
  end

  def previsione
    load_phase(:previsione)
  end

  def responsabile_progettazione
    load_phase(:responsabile_progettazione)
  end

  def step_necessari
    load_phase(:step_necessari)
  end

  def impegno
    load_phase(:impegno)
  end

  def realizzazione
    load_phase(:realizzazione)
  end

  def test
    load_phase(:test)
  end

  def attivo
    load_phase(:attivo)
  end

  def chiuso
    load_phase(:chiuso)
  end
  def index; end

  private

  def set_taxbranch
    @taxbranch = Taxbranch.find(params[:id])
  end

  def load_phase(phase_key)
    @phase_key = phase_key
    @journeys = @taxbranch.journeys.where(journeys_status: phase_key).order(updated_at: :desc)
  end
end
