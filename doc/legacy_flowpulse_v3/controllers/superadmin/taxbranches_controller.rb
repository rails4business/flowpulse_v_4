module Superadmin
  class TaxbranchesController < ApplicationController
    include RequireSuperadmin
    require "csv"
    layout "generaimpresa_taxbranch", only: %i[generaimpresa]

    before_action :set_taxbranch, only: %i[
      show edit update destroy journeys positioning set_link_child
      move_down move_up move_right move_left
      generaimpresa post export_import export import rails4b destroy_with_children reparent_children
    ]
    before_action :load_domains, only: %i[new edit create update]
    before_action :load_services_and_journeys, only: %i[new edit create update]
    before_action :require_superadmin_mode_active_for_writes!, only: %i[
      new edit create update destroy
      set_link_child
      move_down move_up move_right move_left
      destroy_with_children reparent_children
      import export_import
    ]

  # GET /taxbranches or /taxbranches.json
  def index
    # 1. Scope di base in base all'utente
    base_scope =
      if Current.user&.superadmin?
        Taxbranch.all
      else
        Current.user&.lead&.taxbranches || Taxbranch.none
      end

    # 2. Modalità: selezione link vs elenco normale
    @link_parent = nil

    if params[:link_parent_id].present?
      @link_parent_id = params[:link_parent_id].to_i
      @link_parent   = Taxbranch.find_by(id: @link_parent_id)

      # in modalità selezione link: di solito vuoi vedere TUTTI (o quasi)
      scope = base_scope
    else
      # elenco normale: solo radici
      scope = base_scope.where(ancestry: [ nil, "" ])
    end

    # 3. Ricerca testuale (slug, label, category)
    if params[:q].present?
      q = "%#{params[:q].strip}%"
      scope = scope.where(
        "slug ILIKE :q OR slug_label ILIKE :q OR slug_category ILIKE :q",
        q: q
      )
    end

    # 4. Ordinamento finale
    @taxbranches = scope.ordered
  end

  def journeys
    @journeys = @taxbranch.journeys
  end

   def set_link_child
    child  = Taxbranch.find(params[:id])               # quello cliccato in index
    parent = Taxbranch.find(params[:link_parent_id])   # quello da trasformare in link

    if parent.children.any?
      redirect_to superadmin_taxbranch_path(parent),
                  alert: "Questo taxbranch ha figli: non può essere trasformato in link."
      return
    end

    parent.update!(link_child: child)

    redirect_to superadmin_taxbranch_path(parent),
                notice: "Collegato a «#{child.display_label}»."
  end
  # GET /taxbranches/1 or /taxbranches/1.json
  def show
     @taxbranch_node = @taxbranch
     @children = @taxbranch.children.ordered


      @post   = @taxbranch.post || @taxbranch.build_post(lead: Current.user&.lead)
  end

  # GET /taxbranches/new
  def new
    @taxbranch = Current.user.lead.taxbranches.build(
      status:     :draft,
      visibility: :private_node
    )

    if params[:parent_id]
      @taxbranch.parent_id = params[:parent_id] if params[:parent_id].present?
    end
  end


  # GET /taxbranches/1/edit
  def edit
  end


  # POST /taxbranches or /taxbranches.json
  def create
    scope = Current.user.lead.taxbranches
    @taxbranch = scope.build(taxbranch_params)

    # fallback dal query string se non inviato nel form
    @taxbranch.parent_id ||= params[:parent_id].presence


    Taxbranch.transaction do
      @taxbranch.save!
      place_new_taxbranch_for_parent_order!(@taxbranch)
      @taxbranch.normalize_siblings_positions!
    end

    redirect_to superadmin_taxbranch_path(@taxbranch),
                notice: "Creato.#{questionnaire_notice_suffix(@taxbranch)}", status: :see_other
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end


def update
  if @taxbranch.update(taxbranch_params)
    @taxbranch.normalize_siblings_positions!
    redirect_to superadmin_taxbranch_path(@taxbranch),
                notice: "Taxbranch aggiornata.#{questionnaire_notice_suffix(@taxbranch)}", status: :see_other # 303
  else
    render :edit, status: :unprocessable_entity
  end
end

  # DELETE /taxbranches/1 or /taxbranches/1.json
  def destroy
    return if handle_taxbranch_destroy_blockers(@taxbranch)

    if @taxbranch.destroy
      respond_to do |format|
        format.html { redirect_to superadmin_taxbranches_path, notice: "Taxbranch was successfully destroyed.", status: :see_other }
        format.json { head :no_content }
      end
    else
      extra = @taxbranch.errors.full_messages.join(", ")
      flash[:alert] = ("Impossibile eliminare il taxbranch. " \
                       "Rimuovi prima: " + blockers.join(" · ") + (extra.present? ? " · #{extra}" : "")).html_safe
      redirect_back fallback_location: superadmin_taxbranch_path(@taxbranch)
    end
  end

  def destroy_with_children
    return if handle_taxbranch_destroy_blockers(@taxbranch)

    @taxbranch.destroy!
    redirect_to superadmin_taxbranches_path, notice: "Taxbranch e subtree eliminati.", status: :see_other
  end

  def reparent_children
    return if handle_taxbranch_destroy_blockers(@taxbranch)

    parent = @taxbranch.parent
    children = @taxbranch.children.ordered.to_a
    child_ids = children.map(&:id)
    children.each { |child| child.update(parent: parent) }
    @taxbranch.destroy!

    first_child = child_ids.first && Taxbranch.find_by(id: child_ids.first)
    redirect_target =
      if first_child.present?
        superadmin_taxbranch_path(first_child)
      elsif parent.present?
        superadmin_taxbranch_path(parent)
      else
        superadmin_taxbranches_path
      end
    redirect_to(redirect_target, notice: "Taxbranch eliminato, figli spostati.", status: :see_other)
  end
  def move_up
    @taxbranch.normalize_siblings_positions!
    siblings_desc = @taxbranch.parent&.order_des? || false
    siblings_scope = Taxbranch.where(ancestry: @taxbranch.ancestry).order(:position, :id)
    first_sibling = siblings_scope.first
    last_sibling = siblings_scope.last

    if siblings_desc
      if last_sibling&.id == @taxbranch.id
        @taxbranch.insert_at(1)
      else
        @taxbranch.move_lower
      end
    else
      if first_sibling&.id == @taxbranch.id
        @taxbranch.insert_at(siblings_scope.count)
      else
        @taxbranch.move_higher
      end
    end
    @taxbranch.normalize_siblings_positions!
    redirect_back fallback_location: superadmin_taxbranches_path
  end

  def move_down
    @taxbranch.normalize_siblings_positions!
    siblings_desc = @taxbranch.parent&.order_des? || false
    siblings_scope = Taxbranch.where(ancestry: @taxbranch.ancestry).order(:position, :id)
    first_sibling = siblings_scope.first
    last_sibling = siblings_scope.last

    if siblings_desc
      if first_sibling&.id == @taxbranch.id
        @taxbranch.insert_at(siblings_scope.count)
      else
        @taxbranch.move_higher
      end
    else
      if last_sibling&.id == @taxbranch.id
        @taxbranch.insert_at(1)
      else
        @taxbranch.move_lower
      end
    end
    @taxbranch.normalize_siblings_positions!
    redirect_back fallback_location: superadmin_taxbranches_path
  end

  def move_left
    old_ancestry = @taxbranch.ancestry
    parent = @taxbranch.parent
    new_parent = parent&.parent

    Taxbranch.transaction do
      @taxbranch.update!(parent: new_parent)
      place_new_taxbranch_for_parent_order!(@taxbranch)
      Taxbranch.normalize_positions_for_ancestry!(old_ancestry)
      @taxbranch.normalize_siblings_positions!
    end

    redirect_back fallback_location: superadmin_taxbranches_path
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: superadmin_taxbranches_path, alert: e.message
  end

  def move_right
    old_ancestry = @taxbranch.ancestry
    siblings_desc = @taxbranch.parent&.order_des? || false
    previous = siblings_desc ? @taxbranch.lower_item : @taxbranch.higher_item

    if previous.present?
      Taxbranch.transaction do
        @taxbranch.update!(parent: previous)
        place_new_taxbranch_for_parent_order!(@taxbranch)
        Taxbranch.normalize_positions_for_ancestry!(old_ancestry)
        @taxbranch.normalize_siblings_positions!
      end
    end

    redirect_back fallback_location: superadmin_taxbranches_path
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: superadmin_taxbranches_path, alert: e.message
  end

  def positioning
    @taxbranch_node = @taxbranch
    rows = @taxbranch.tag_positionings
    counts = rows.group(:name, :category).count
    @items = counts.map { |(name, cat), n| { text: name, count: n, cat: cat } }
       @tags_by_category = @taxbranch.tag_positionings.order(:category, :name).group_by(&:category)
  end

  def generaimpresa
    @domain = @taxbranch.header_domain
    root = @taxbranch
    subtree = @taxbranch.subtree
    current_tab = params[:tab].presence || "generaimpresa"
    @graph_root_id = @taxbranch.id

    @graph_nodes = subtree.map do |tb|
      full_label = tb.display_label.to_s
      short_label = full_label.length > 18 ? "#{full_label[0, 18]}…" : full_label
      {
        id: tb.id,
        label: short_label,
        title: full_label,
        url: generaimpresa_superadmin_taxbranch_path(tb, tab: current_tab)
      }
    end
    @graph_edges = subtree.filter_map do |tb|
      next unless tb.parent_id

      { from: tb.parent_id, to: tb.id }
    end
  end

  def rails4b
    load_rails4b_data
    render :rails4b, layout: "generaimpresa_taxbranch"
  end

  def post
    @post = @taxbranch.post || @taxbranch.build_post(lead: Current.user&.lead)
  end


  def export_import
    @default_lead_id = Current.user&.lead_id
  end

  def export
    subtree = @taxbranch.subtree.order(:ancestry, :position, :slug_label)

    bom = "\uFEFF"
    csv = CSV.generate(headers: true) do |out|
      out << %w[
        slug slug_category slug_label parent_slug lead_id visibility status position home_nav
        scheduled_eventdate_id published_at order_des phase notes meta permission_access_roles positioning_tag_public
        service_certificable x_coordinated y_coordinated link_child_slug
        post_title post_description post_content_md post_content post_slug post_lead_id
        post_thumb_url post_horizontal_cover_url post_vertical_cover_url post_banner_url post_url_media_content
      ]
      subtree.each do |tb|
        post = tb.post
        row = [
          tb.slug,
          tb.slug_category,
          tb.slug_label,
          tb.parent&.slug,
          tb.lead_id,
          tb.visibility,
          tb.status,
          tb.position,
          tb.home_nav,
          tb.scheduled_eventdate_id,
          tb.published_at&.iso8601,
          tb.order_des,
          tb.phase,
          tb.notes,
          tb.meta&.to_json,
          tb.permission_access_roles&.to_json,
          tb.positioning_tag_public,
          tb.service_certificable,
          tb.x_coordinated,
          tb.y_coordinated,
          tb.link_child&.slug,
          post&.title,
          post&.description,
          post&.content_md,
          post&.content,
          post&.slug,
          post&.lead_id,
          post&.thumb_url,
          post&.horizontal_cover_url,
          post&.vertical_cover_url,
          post&.banner_url,
          post&.url_media_content
        ]
        out << row.map { |val| val.is_a?(String) ? val.encode("UTF-8", invalid: :replace, undef: :replace, replace: "") : val }
      end
    end

    filename = "taxbranches_subtree_#{@taxbranch.id}_#{Time.zone.now.strftime('%Y%m%d_%H%M')}.csv"
    send_data bom + csv, filename: filename, type: "text/csv; charset=utf-8"
  end

  def import
    file = params[:file]
    duplicate_mode = params[:duplicate_mode].presence || "skip"
    lead_id_default = params[:lead_id].presence || Current.user&.lead_id

    unless file
      redirect_to export_import_superadmin_taxbranch_path(@taxbranch), alert: "Seleziona un file CSV."
      return
    end

    raw = file.read
    raw = raw.force_encoding("UTF-8")
    raw = raw.encode("UTF-8", invalid: :replace, undef: :replace, replace: "") if raw.respond_to?(:encode)
    raw = strip_utf8_bom(raw)
    col_sep = detect_csv_separator(raw)
    rows = CSV.parse(raw, headers: true, col_sep: col_sep)
    results = { created: 0, updated: 0, skipped: 0, errors: [] }
    post_results = { created: 0, updated: 0, skipped: 0 }
    imported = []
    slug_map = {}

    Taxbranch.transaction do
      rows.each_with_index do |row, idx|
        row = row.to_h.transform_keys { |key| normalize_csv_header_key(key) }
                 .transform_values do |val|
          val.is_a?(String) ? val.encode("UTF-8", invalid: :replace, undef: :replace, replace: "") : val
        end
        row = row.with_indifferent_access
        slug = row["slug"].to_s.strip
        if slug.blank?
          results[:errors] << "Riga #{idx + 2}: slug mancante."
          next
        end

        tb = Taxbranch.find_by(slug: slug)
        lead_id =
          if row["lead_id"].present? && Lead.exists?(row["lead_id"])
            row["lead_id"]
          elsif lead_id_default.present? && Lead.exists?(lead_id_default)
            lead_id_default
          else
            nil
          end

        attrs = {
          slug: slug,
          slug_category: row["slug_category"].presence,
          slug_label: row["slug_label"].presence,
          lead_id: lead_id,
          visibility: row["visibility"].presence,
          status: row["status"].presence,
          home_nav: parse_bool(row["home_nav"]),
          scheduled_eventdate_id: row["scheduled_eventdate_id"].presence,
          published_at: row["published_at"].presence,
          order_des: parse_bool(row["order_des"]),
          phase: row["phase"].presence,
          notes: row["notes"].presence,
          meta: parse_json(row["meta"]),
          permission_access_roles: parse_json_array(row["permission_access_roles"]),
          positioning_tag_public: parse_bool(row["positioning_tag_public"]),
          service_certificable: parse_bool(row["service_certificable"]),
          x_coordinated: row["x_coordinated"].presence,
          y_coordinated: row["y_coordinated"].presence
        }.compact

        if tb
          case duplicate_mode
          when "skip"
            results[:skipped] += 1
            slug_map[slug] = tb.id
            next
          when "error"
            results[:errors] << "Riga #{idx + 2}: slug già esistente (#{slug})."
            next
          else
            tb.assign_attributes(attrs.except(:slug))
            tb.save!
            results[:updated] += 1
          end
        else
          tb = Taxbranch.new(attrs)
          tb.save!
          results[:created] += 1
        end

        post_lead_id =
          if row["post_lead_id"].present? && Lead.exists?(row["post_lead_id"])
            row["post_lead_id"]
          elsif lead_id_default.present? && Lead.exists?(lead_id_default)
            lead_id_default
          elsif tb.lead_id.present? && Lead.exists?(tb.lead_id)
            tb.lead_id
          else
            nil
          end

        slug_map[slug] = tb.id
        imported << {
          tb: tb,
          parent_slug: row["parent_slug"].to_s.strip.presence,
          link_child_slug: row["link_child_slug"].to_s.strip.presence,
          row_index: idx,
          position: row["position"].to_s.strip,
          post_data: {
            title: row["post_title"].presence,
            description: row["post_description"].presence,
            content_md: row["post_content_md"].presence,
            content: row["post_content"].presence,
            slug: row["post_slug"].presence,
            lead_id: post_lead_id,
            thumb_url: row["post_thumb_url"].presence,
            horizontal_cover_url: row["post_horizontal_cover_url"].presence,
            vertical_cover_url: row["post_vertical_cover_url"].presence,
            banner_url: row["post_banner_url"].presence,
            url_media_content: row["post_url_media_content"].presence
          }
        }
      end

      imported.each do |item|
        tb = item[:tb]
        parent_slug = item[:parent_slug]

        parent_id =
          if parent_slug.present?
            slug_map[parent_slug]
          else
            @taxbranch.id
          end

        if parent_id.nil?
          parent_id = @taxbranch.id
          results[:errors] << "Slug parent non trovato per #{tb.slug} (#{parent_slug}); assegnato a #{@taxbranch.slug}."
        end

        tb.update!(parent_id: parent_id)
      end

      imported.each do |item|
        tb = item[:tb]
        link_child_slug = item[:link_child_slug]
        next if link_child_slug.blank?
        link_child_id = slug_map[link_child_slug]
        next if link_child_id.blank?
        tb.update!(link_child_taxbranch_id: link_child_id)
      end

      groups = imported.group_by { |i| i[:tb].parent_id }
      groups.each_value do |items|
        ordered = items.sort_by do |i|
          pos = i[:position].to_i
          pos.positive? ? pos : (i[:row_index] + 1)
        end
        ordered.each_with_index do |i, index|
          i[:tb].insert_at(index + 1)
        end
      end

      imported.each do |item|
        tb = item[:tb]
        post_data = item[:post_data]
        next unless post_data.values.any?(&:present?)

        post = tb.post
        if post
          case duplicate_mode
          when "skip"
            post_results[:skipped] += 1
            next
          when "error"
            results[:errors] << "Post già esistente per #{tb.slug}."
            next
          else
            post_data[:title] ||= tb.slug_label
            post.assign_attributes(post_data.compact)
            if post.lead_id.blank?
              results[:errors] << "Post per #{tb.slug}: lead_id mancante o non valido."
              next
            end
            if post.save
              post_results[:updated] += 1
            else
              results[:errors] << "Post per #{tb.slug}: #{post.errors.full_messages.join(', ')}"
            end
          end
        else
          post_data[:title] ||= tb.slug_label
          post = tb.build_post(post_data.compact)
          if post.lead_id.blank?
            results[:errors] << "Post per #{tb.slug}: lead_id mancante o non valido."
            next
          end
          if post.save
            post_results[:created] += 1
          else
            results[:errors] << "Post per #{tb.slug}: #{post.errors.full_messages.join(', ')}"
          end
        end
      end
    end

    notice = "Import completato. Taxbranch creati: #{results[:created]}, aggiornati: #{results[:updated]}, saltati: #{results[:skipped]}. Post creati: #{post_results[:created]}, aggiornati: #{post_results[:updated]}, saltati: #{post_results[:skipped]}."
    if results[:errors].any?
      redirect_to superadmin_taxbranch_path(@taxbranch), alert: "#{notice} Errori: #{results[:errors].join(' | ')}"
    else
      redirect_to superadmin_taxbranch_path(@taxbranch), notice: notice
    end
  rescue CSV::MalformedCSVError => e
    redirect_to superadmin_taxbranch_path(@taxbranch), alert: "CSV non valido: #{e.message}"
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_taxbranch
        @taxbranch =
          if Taxbranch.respond_to?(:friendly)
            Taxbranch.friendly.find(params[:id])
          else
            Taxbranch.find_by(id: params[:id]) || Taxbranch.find_by(slug: params[:id])
          end

        redirect_to superadmin_taxbranches_path, alert: "Taxbranch non trovato." if @taxbranch.nil?

  rescue ActiveRecord::RecordNotFound
    redirect_to superadmin_taxbranches_path, alert: "Taxbranch non trovato."
  end




   # Only allow a list of trusted parameters through.
  def taxbranch_params
    permitted = params.require(:taxbranch).permit(
      :lead_id, :notes, :slug, :slug_category, :slug_label,
      :ancestry, :position, :meta, :questionnaire_config, :questionnaire_source, :questionnaire_version, :parent_id, :home_nav,
      :x_coordinated, :y_coordinated,
      :positioning_tag_public, :service_certificable,
      :status, :visibility, :phase, :published_at, :scheduled_eventdate_id, :order_des, :generaimpresa_md,
      :execution_mode,
      permission_access_roles: [],
      performed_by_roles: [],
      target_roles: []
    )
    attrs = permitted.to_h.symbolize_keys

    if attrs[:meta].is_a?(String)
      stripped = attrs[:meta].strip
      attrs[:meta] = stripped.present? ? (parse_json(stripped) || attrs[:meta]) : {}
    end
    if attrs[:questionnaire_config].is_a?(String)
      stripped = attrs[:questionnaire_config].strip
      attrs[:questionnaire_config] = stripped.present? ? (parse_json(stripped) || attrs[:questionnaire_config]) : {}
    end

    merge_questionnaire_meta!(attrs)

    attrs
  end

  def merge_questionnaire_meta!(attrs)
    questionnaire_category =
      attrs[:slug_category].to_s.presence || @taxbranch&.slug_category.to_s
    return unless questionnaire_category == "questionnaire"

    incoming_source = attrs.delete(:questionnaire_source).to_s.strip.presence
    version = attrs.delete(:questionnaire_version).to_s.strip.presence
    existing_config = @taxbranch&.questionnaire_config.is_a?(Hash) ? @taxbranch.questionnaire_config.deep_dup : {}
    source = incoming_source.presence || existing_config["questionnaire_source"].to_s.presence

    if source.blank?
      # No source provided and none already persisted: keep config as-is so validation can explain.
      attrs[:questionnaire_config] = existing_config if attrs[:questionnaire_config].blank?
      return
    end

    attrs[:questionnaire_config] = (attrs[:questionnaire_config].is_a?(Hash) ? attrs[:questionnaire_config] : {})
      .merge("questionnaire_source" => source)

    path = Rails.root.join(source.to_s.sub(%r{\A/+}, "")).to_s
    if File.exist?(path)
      begin
        yaml = YAML.safe_load_file(path, permitted_classes: [], aliases: false) || {}
        inferred = version.presence || yaml["version"].to_s.strip.presence
        attrs[:questionnaire_config]["questionnaire_version"] = inferred if inferred.present?
        attrs[:questionnaire_config]["scoring"] = yaml["scoring"] if yaml["scoring"].is_a?(Hash)
      rescue Psych::Exception
        attrs[:questionnaire_config]["questionnaire_version"] = version if version.present?
      end
    elsif version.present?
      attrs[:questionnaire_config]["questionnaire_version"] = version
    end
  end

  def questionnaire_notice_suffix(taxbranch)
    return "" unless taxbranch&.slug_category.to_s == "questionnaire"

    source = taxbranch.questionnaire_source.to_s.presence
    path = taxbranch.questionnaire_source_path.to_s.presence
    return "" if source.blank? && path.blank?

    " Questionario: #{source || '(fallback)'}#{path.present? ? " (#{path})" : ''}"
  end

  def load_domains
    @available_domains = Domain.order(:title)
  end

  def load_services_and_journeys
    @available_services = Service.order(:name)
    @available_journeys = Journey.order(:title)
  end

  def require_superadmin_mode_active_for_writes!
    return if Current.user&.superadmin_mode_active?

    redirect_to superadmin_taxbranches_path, alert: "Attiva la modalita superadmin per modificare i taxbranch."
  end

  def place_new_taxbranch_for_parent_order!(taxbranch)
    parent = taxbranch.parent
    return if parent.blank?

    siblings_count = Taxbranch.where(ancestry: taxbranch.ancestry).count
    target_position = parent.order_des? ? 1 : siblings_count
    taxbranch.insert_at(target_position)
  end

  def parse_bool(value)
    case value.to_s.strip.downcase
    when "1", "true", "yes", "y", "on"
      true
    when "0", "false", "no", "n", "off"
      false
    else
      nil
    end
  end

  def parse_json(value)
    return nil if value.blank?
    JSON.parse(value.to_s)
  rescue JSON::ParserError
    nil
  end

  def parse_json_array(value)
    parsed = parse_json(value)
    return parsed if parsed.is_a?(Array)
    return nil if value.blank?
    value.to_s.split(/[\n,;]/).map(&:strip).reject(&:blank?)
  end

  def detect_csv_separator(raw)
    header_line = raw.to_s.lines.first.to_s
    semicolons = header_line.count(";")
    commas = header_line.count(",")
    semicolons > commas ? ";" : ","
  end

  def normalize_csv_header_key(key)
    key.to_s
       .encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
       .sub(/\A\uFEFF/, "")
       .strip
  end

  def strip_utf8_bom(value)
    value.to_s.sub(/\A\uFEFF/, "")
  end

  def handle_taxbranch_destroy_blockers(taxbranch)
    blockers = []
    services = Service.where(taxbranch_id: taxbranch.id)
    if services.exists?
      services.limit(5).each do |service|
        blockers << view_context.link_to("Service ##{service.id}", superadmin_service_path(service))
      end
      extra = services.count - 5
      blockers << "(+#{extra})" if extra.positive?
    end
    taxbranch.post&.destroy
    if taxbranch.journeys.exists?
      blockers << view_context.link_to(
        "Journeys (#{taxbranch.journeys.count})",
        journeys_superadmin_taxbranch_path(taxbranch)
      )
    end
    if taxbranch.incoming_journeys.exists?
      blockers << view_context.link_to(
        "Journeys in arrivo (#{taxbranch.incoming_journeys.count})",
        journeys_path(end_taxbranch_id: taxbranch.id)
      )
    end
    domain = taxbranch.domains.first
    if domain.present?
      blockers << view_context.link_to("Domain ##{domain.id}", superadmin_domain_path(domain))
    end
    if taxbranch.eventdates.exists?
      blockers << view_context.link_to("Eventdate (#{taxbranch.eventdates.count})", eventdates_path(taxbranch_id: taxbranch.id))
    end

    if blockers.any?
      flash[:alert] = ("Impossibile eliminare il taxbranch finché esistono elementi collegati. " \
                       "Rimuovi prima: " + blockers.join(" · ")).html_safe
      if services.exists?
        redirect_to superadmin_services_path(taxbranch_id: taxbranch.id)
      elsif domain.present?
        redirect_to superadmin_domain_path(domain)
      else
        redirect_back fallback_location: superadmin_taxbranch_path(taxbranch)
      end
      return true
    end

    false
  end
  end
end
  def load_rails4b_data
    @domain = @taxbranch.header_domain
    @direction = params[:direction].presence || "all"
    @type_filter = params[:type].presence || "all"
    @mode_filter = params[:mode].presence || params[:tab].presence || "all"
    @service = @taxbranch.service

    outgoing = Journey.where(taxbranch_id: @taxbranch.id)
    incoming = Journey.where(end_taxbranch_id: @taxbranch.id)
    base_scope =
      case @direction
      when "outgoing"
        outgoing
      when "incoming"
        incoming
      else
        Journey.where(id: outgoing.select(:id)).or(Journey.where(id: incoming.select(:id)))
      end

    @journeys = base_scope.includes(:taxbranch, :end_taxbranch, :service).order(updated_at: :desc)

    @journeys =
      case @mode_filter
      when "builders"
        @journeys.cycle_template
      when "drivers"
        @journeys.cycle_instance
      else
        @journeys
      end

    @journeys_by_type = {
      railservice: [],
      function: [],
      pure: []
    }

    @journeys.each do |journey|
      if journey.railservice?
        @journeys_by_type[:railservice] << journey
      elsif journey.journey_function?
        @journeys_by_type[:function] << journey
      else
        @journeys_by_type[:pure] << journey
      end
    end
  end
