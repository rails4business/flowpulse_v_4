class PagesController < ApplicationController
  # skip_after_action :verify_policy_scoped, raise: false
  # skip_after_action :verify_authorized,    raise: false
  # after_action :verify_policy_scoped, only: :index

  allow_unauthenticated_access
  layout "landing"

  def signup
    @lead = Lead.new
    @ref_lead = Lead.find_by(token: params[:ref]) if params[:ref].present?
    @parent_lead = Lead.find_by(id: params[:parent_id]) if params[:parent_id].present?
  end
  # app/controllers/pages_controller.rb

  def home
    # 1️⃣ trova la radice del dominio corrente o la prima tassonomia principale
    @taxbranch = Current.taxbranch || Taxbranch.where(ancestry: nil).ordered.first
    @taxbranch_node = @taxbranch
    return render file: Rails.root.join("public/404.html"), status: :not_found, layout: false unless @taxbranch

    # 2️⃣ figli diretti da mostrare in home
    @children  = @taxbranch.children.ordered

    # 3️⃣ voci della navbar (solo figli con home_nav:true)
    @nav_items = @taxbranch.children.home_nav

    # 4️⃣ (opzionale) caching per dominio + taxbranch
    # cache_key = ["home", Current.domain&.host, @taxbranch.cache_key_with_version]
    # @children = Rails.cache.fetch(cache_key, expires_in: 10.minutes) { @children.to_a }
  end

  # def home
  #   data = YAML.load_file(Rails.root.join("config/brands_services/flowpulse.yml")).deep_symbolize_keys
  #   @services = data[:services].select { |s| s[:visible] }
  #   @brands_by_category = data[:brands].select { |b| b[:visible] }.group_by { |b| b[:category] }
  # end

  def posturacorretta
  end

  def igiene_posturale
  end

  def insegnanti
    file_path = Rails.root.join("config/data/professionisti.json")
    @professionisti = JSON.parse(File.read(file_path))
  rescue StandardError => e
    Rails.logger.error("Errore caricamento professionisti.json: #{e.class} - #{e.message}")
    @professionisti = []
  end

  def about
  end

  def contact
  end

  def coming_soon
    @feature = params[:feature].to_s.strip.presence || "Questa sezione"
    @source = params[:source].to_s.strip.presence
    source_suffix = @source.present? ? " (da: #{@source})" : ""
    fallback_message = "Ciao! Sono interessato a #{@feature}#{source_suffix}. Quando sara disponibile?"
    @wa_message = params[:wa_message].to_s.strip.presence || fallback_message
    @wa_number = "393290706039"
    @wa_url = "https://wa.me/#{@wa_number}?text=#{ERB::Util.url_encode(@wa_message)}"
  end
end
