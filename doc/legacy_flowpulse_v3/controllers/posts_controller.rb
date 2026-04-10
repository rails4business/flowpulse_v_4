class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[show mark_done pricing]

  before_action :set_post,         only: %i[edit update destroy]
  before_action :set_post_public,  only: %i[show mark_done pricing submit_questionnaire]
  before_action :set_superadmin,   except: %i[show mark_done pricing submit_questionnaire]

  helper_method :sort_column, :sort_direction

  layout "application", except: %i[show pricing]

  # ----------------------------------------------------
  # MARK_DONE → registra l'evento di esercizio completato
  # ----------------------------------------------------
  def mark_done
    lead = Current.user&.lead || (defined?(current_lead) ? current_lead : nil)
    unless lead
      redirect_back fallback_location: post_path(params[:id]), alert: "Devi essere autenticato per registrare l'esercizio."
      return
    end

    taxbranch = Taxbranch.find_by(id: params[:taxbranch_id])
    unless taxbranch
      redirect_back fallback_location: post_path(params[:id]), alert: "Impossibile trovare l'esercizio da marcare."
      return
    end

    last_event = Eventdate.where(lead: lead, taxbranch: taxbranch).order(cycle: :desc).first
    new_cycle  = last_event ? last_event.cycle + 1 : 1

    event = Eventdate.new(
      taxbranch:  taxbranch,
      lead:       lead,
      date_start: Time.current,
      date_end:   Time.current,
      cycle:      new_cycle,
      status:     :completed # enum
    )

    if event.save
      begin
        lead.activities.create!(
          domain: Current.domain,
          taxbranch: taxbranch,
          eventdate: event,
          kind: "step_completed",
          status: "recorded",
          occurred_at: event.date_start || Time.current,
          source: "post_mark_done",
          source_ref: @post&.slug.presence || taxbranch.slug
        )
      rescue StandardError => e
        Rails.logger.warn("Activity non salvata in mark_done: #{e.class} - #{e.message}")
      end

      redirect_back fallback_location: post_path(params[:id]),
                    notice: "🎉 Esercizio “#{taxbranch.post&.title || 'senza titolo'}” completato (ciclo #{new_cycle})."
    else
      redirect_back fallback_location: post_path(params[:id]),
                    alert: "Errore nel salvataggio: #{event.errors.full_messages.to_sentence}"
    end
  rescue => e
    Rails.logger.error "Errore in mark_done: #{e.message}"
    redirect_back fallback_location: post_path(params[:id]),
                  alert: "Si è verificato un errore inatteso."
  end

  # ----------------
  # GET /posts (admin)
  # ----------------
  def index
    @taxbranches = Taxbranch.order(:slug_label)

    # base scope: includi taxbranch e lead, e fai join con taxbranch perché filtriamo/ordiniamo su di lui
    scope = Post.includes(:taxbranch, :lead).joins(:taxbranch)

    # filtro per taxbranch specifico
    scope = scope.where(taxbranch_id: params[:taxbranch_id]) if params[:taxbranch_id].present?

    # filtro per status EDITORIALE del taxbranch
    if params[:status].present? && Taxbranch.statuses.key?(params[:status])
      scope = scope.where(taxbranches: { status: Taxbranch.statuses[params[:status]] })
    end

    # filtro per published_at (sul taxbranch)
    if params[:after].present?
      from = Time.zone.parse(params[:after]) rescue nil
      scope = scope.where("taxbranches.published_at >= ?", from) if from
    end

    if params[:before].present?
      to = Time.zone.parse(params[:before]) rescue nil
      scope = scope.where("taxbranches.published_at <= ?", to) if to
    end

    # ------ ORDINAMENTO SICURO ------
    p  = Post.arel_table
    tb = Taxbranch.arel_table
    dir = (sort_direction == "asc" ? :asc : :desc)

    if sort_column == "tax"
      coalesce = Arel::Nodes::NamedFunction.new("COALESCE", [ tb[:slug_label], tb[:slug] ])
      nulls_last_flag = Arel::Nodes::Case.new(coalesce).when(nil).then(1).else(0)

      scope = scope
        .order(nulls_last_flag.asc)
        .order(dir == :asc ? coalesce.asc : coalesce.desc)
    else
      allowed = {
        "title"        => p[:title],
        "status"       => tb[:status],        # ora status è sul taxbranch
        "published_at" => tb[:published_at],  # idem published_at
        "created_at"   => p[:created_at]
      }
      col = allowed[sort_column] || tb[:published_at]
      scope = scope.order(dir == :asc ? col.asc : col.desc)
    end

    scope  = scope.order(id: :desc)
    @posts = scope.page(params[:page]).per(20)
  end

  # ------------------------
  # GET /posts/:id (pubblico)
  # ------------------------
  def show
    @taxbranch      = @post.taxbranch
    @taxbranch_node = @post.taxbranch

    @children  = @taxbranch.children.ordered
    @nav_items = @taxbranch.children.home_nav

    slug = @post.taxbranch&.slug_category&.parameterize&.underscore
    request.variant =
      if @taxbranch&.questionnaire_source_path.present? || @taxbranch&.questionnaire_root?
        :questionnaire
      else
        slug.present? ? slug.to_sym : nil
      end
    load_questionnaire_for_show if request.variant == :questionnaire

    Rails.logger.info "🧩 Variant attiva: #{request.variant.inspect}"
  end

  # -----------------------------
  # GET /posts/:id/pricing (pubblico)
  # -----------------------------
  def pricing
    @taxbranch      = @post.taxbranch
    @taxbranch_node = @post.taxbranch
    @services       = Array(@taxbranch&.service).compact

    slug = @taxbranch&.slug_category&.parameterize&.underscore
    request.variant = slug.present? ? slug.to_sym : nil

    Rails.logger.info "🧩 Variant attiva (pricing): #{request.variant.inspect}"
  end

  def submit_questionnaire
    lead = Current.user&.lead
    unless lead
      if params[:in_dashboard].to_s == "1"
        redirect_to dashboard_home_path(tab: params[:tab].presence || "academy"), alert: "Devi essere autenticato per inviare il questionario."
      else
        redirect_to login_path, alert: "Devi essere autenticato per inviare il questionario."
      end
      return
    end

    questionnaire_taxbranch = @post.taxbranch
    has_yaml_questionnaire = questionnaire_taxbranch&.questionnaire_source_path.present?
    unless questionnaire_taxbranch&.questionnaire_root? || has_yaml_questionnaire
      if params[:in_dashboard].to_s == "1"
        redirect_to dashboard_home_path(tab: params[:tab].presence || "academy"), alert: "Questo post non e un questionario."
      else
        redirect_to post_path(@post), alert: "Questo post non e un questionario."
      end
      return
    end

    answers = submitted_questionnaire_answers
    missing = missing_required_questionnaire_answers(questionnaire_taxbranch, answers)
    if missing.any?
      first_missing_code = missing.first
      target_q = questionnaire_question_position(questionnaire_taxbranch, first_missing_code)
      if params[:in_dashboard].to_s == "1"
        redirect_to dashboard_home_path(
          tab: params[:tab].presence || "academy",
          open_activity_modal: 1,
          activity_id: params[:activity_id],
          post_id: @post.slug,
          q: target_q
        ), alert: "Completa tutte le domande obbligatorie prima di inviare."
      else
        redirect_to post_path(@post, q: target_q), alert: "Completa tutte le domande obbligatorie prima di inviare."
      end
      return
    end

    if answers.blank?
      if params[:in_dashboard].to_s == "1"
        redirect_to dashboard_home_path(
          tab: params[:tab].presence || "academy",
          open_activity_modal: 1,
          activity_id: params[:activity_id],
          post_id: @post.slug,
          q: params[:q].presence || 1
        ), alert: "Seleziona almeno una risposta prima di inviare."
      else
        redirect_to post_path(@post, q: params[:q].presence || 1), alert: "Seleziona almeno una risposta prima di inviare."
      end
      return
    end

    activity = QuestionnaireSubmission.call(
      lead: lead,
      questionnaire_taxbranch: questionnaire_taxbranch,
      answers: answers,
      occurred_at: Time.current,
      description: "Questionario inviato da #{lead.full_name.presence || lead.username.presence || "lead##{lead.id}"}",
      source_ref: @post.slug
    )

    result_activity_for_redirect = activity
    if params[:in_dashboard].to_s == "1" && params[:activity_id].present?
      dashboard_activity = lead.activities.find_by(id: params[:activity_id], taxbranch_id: questionnaire_taxbranch.id)
      if dashboard_activity.present?
        payload = dashboard_activity.payload.is_a?(Hash) ? dashboard_activity.payload.deep_dup : {}
        payload["answers"] = answers
        submitted_payload = activity.payload.is_a?(Hash) ? activity.payload : {}
        payload["answers_detailed"] = submitted_payload["answers_detailed"] if submitted_payload["answers_detailed"].present?
        payload["questionnaire_snapshot"] = submitted_payload["questionnaire_snapshot"] if submitted_payload["questionnaire_snapshot"].present?
        payload["questionnaire_version"] = submitted_payload["questionnaire_version"] if submitted_payload["questionnaire_version"].present?
        payload["questionnaire_post_slug"] = @post.slug
        payload["submitted_at"] = Time.current.iso8601

        dashboard_activity.update(
          kind: "step_completed",
          payload: payload,
          status: "archived",
          occurred_at: Time.current,
          score_total: activity.score_total,
          score_max: activity.score_max,
          level_code: activity.level_code
        )
        result_activity_for_redirect = dashboard_activity
      end
    end

    if params[:in_dashboard].to_s == "1" || params[:return_to_dashboard].to_s == "1"
      redirect_to dashboard_home_path(tab: params[:tab].presence || "academy"),
                  notice: "Questionario salvato. Risultato: #{activity.level_code.presence || 'n/d'} (#{activity.score_total || 0}/#{activity.score_max || 0})."
    else
      redirect_to post_path(@post, q: params[:q].presence || 1, result_activity_id: activity.id), notice: "Questionario salvato. Risultato: #{activity.level_code.presence || 'n/d'} (#{activity.score_total || 0}/#{activity.score_max || 0})."
    end
  rescue QuestionnaireSubmission::Error => e
    if params[:in_dashboard].to_s == "1"
      redirect_to dashboard_home_path(
        tab: params[:tab].presence || "academy",
        open_activity_modal: 1,
        activity_id: params[:activity_id],
        post_id: @post.slug,
        q: params[:q].presence || 1
      ), alert: e.message
    else
      redirect_to post_path(@post, q: params[:q].presence || 1), alert: e.message
    end
  end

  # GET /posts/new
  def new
    @post = Current.user.lead.posts.build
    taxbranch_id = params.dig(:post, :taxbranch_id).presence || params[:taxbranch_id].presence
    @post.taxbranch_id = taxbranch_id if taxbranch_id.present?
  end

  # GET /posts/:id/edit
  def edit
  end

  # POST /posts
  def create
    @post = Current.user.lead.posts.build(post_params)

    if @post.save
      redirect_to [ :superadmin, @post.taxbranch ], notice: "Post creato.", status: :see_other
    else
      @taxbranch = @post.taxbranch || Taxbranch.find_by(id: params.dig(:post, :taxbranch_id))
      if @taxbranch.present?
        @children  = @taxbranch.children.ordered.includes(:domains)
        render "superadmin/taxbranches/show", status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /posts/:id
  def update
    if @post.update(post_params)
      redirect_to [ :superadmin, @post.taxbranch ], notice: "Post aggiornato.", status: :see_other
    else
      @taxbranch = @post.taxbranch || Taxbranch.find_by(id: params.dig(:post, :taxbranch_id))
      if @taxbranch.present?
        @children  = @taxbranch.children.ordered.includes(:domains)
        render "superadmin/taxbranches/show", status: :unprocessable_entity
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  # DELETE /posts/:id
  def destroy
    tb = @post.taxbranch
    @post.destroy!
    redirect_to [ :superadmin, tb ], notice: "Post eliminato.", status: :see_other
  end

  private

  # Solo per edit/update/destroy
  def set_post
    return unless params[:id].present?
    @post = Post.includes(:taxbranch).friendly.find(params[:id])
  end

  # 🔓 Scelta del post "pubblico" per show/mark_done

  def set_post_public
  # Flussi interni autenticati (dashboard) non devono passare dai vincoli di pubblicazione.
  if (params[:in_dashboard].to_s == "1" || params[:return_to_dashboard].to_s == "1") && Current.user.present? && params[:id].present?
    @post = Post.includes(:taxbranch).friendly.find(params[:id])
    @taxbranch = @post.taxbranch
    return
  end

  # 1️⃣ Se c'è un id esplicito → usa solo FriendlyId + controlli editoriali
  if params[:id].present?
    @post = Post.includes(:taxbranch).friendly.find(params[:id])

    unless post_published_for_public?(@post)
      redirect_to root_path, alert: "Il post non è pubblicato." and return
    end

    @taxbranch = @post.taxbranch
    return
  end

  # 2️⃣ Nessun id: prova col taxbranch del dominio corrente
  domain_taxbranch = Current.domain&.taxbranch

  if domain_taxbranch
    @taxbranch = domain_taxbranch
    @post      = domain_taxbranch.post

    # Se il post non esiste o non è pubblicabile, prova sui figli visibili
    unless @post && post_published_for_public?(@post)
      visible_children_ids = domain_taxbranch.children
                                             .where(
                                               status:     Taxbranch.statuses[:published],
                                               visibility: Taxbranch.visibilities[:public_node]
                                             )
                                             .pluck(:id)

      @post = Post.joins(:taxbranch)
                  .where(taxbranches: { id: visible_children_ids })
                  .first
    end
  end

# 3️⃣ Fallback globale: qualsiasi post pubblicabile
# 3️⃣ Fallback globale: qualsiasi post pubblicabile
@post ||= Post.joins(:taxbranch)
              .where(
                taxbranches: {
                  status:     Taxbranch.statuses[:published],
                  visibility: Taxbranch.visibilities[:public_node]
                }
              )
              .where("taxbranches.published_at IS NULL OR taxbranches.published_at <= ?", Time.current)
              .order(
                Arel.sql("COALESCE(taxbranches.published_at, taxbranches.created_at) DESC")
              )
              .first


  if @post.nil?
    redirect_to posts_path, alert: "Nessun post pubblicato disponibile." and return
  end

  @taxbranch ||= @post.taxbranch
end

  # Logica di visibilità: usa LO STATO DEL TAXBRANCH (non più quello del post)
  def post_published_for_public?(post)
    tb = post.taxbranch
    return false unless tb

    # stato editoriale
    return false unless tb.published?
    # visibilità
    return false unless tb.public_node?
    # data di pubblicazione (se c'è)
    return false if tb.published_at.present? && tb.published_at > Time.current

    true
  end

  def load_questionnaire_for_show
    @questionnaire_source = @taxbranch.questionnaire_source
    @questionnaire_version = @taxbranch.questionnaire_version
    @questionnaire_data = @taxbranch.questionnaire_definition
    fallback = nil

    if extract_questionnaire_questions(@questionnaire_data).blank?
      fallback = load_questionnaire_fallback_data
      if fallback.present?
        @questionnaire_data = fallback[:data]
        @questionnaire_source = fallback[:source].to_s.presence || @questionnaire_source
        @questionnaire_version = fallback[:version].to_s.presence || @questionnaire_version
        sync_questionnaire_meta_from_fallback!(fallback)
      end
    end

    raw_questions = extract_questionnaire_questions(@questionnaire_data)
    @questionnaire_questions = Array(raw_questions).sort_by { |q| q["position"].to_i }
    raw_scoring = questionnaire_hash_value(@questionnaire_data, "scoring")
    @questionnaire_scoring = raw_scoring.is_a?(Hash) ? raw_scoring : {}
    @questionnaire_debug = {
      source: @questionnaire_source.presence || "(vuoto)",
      file_exists: questionnaire_source_file_exists?(@questionnaire_source),
      top_level_keys: @questionnaire_data.is_a?(Hash) ? @questionnaire_data.keys : [],
      questions_count: @questionnaire_questions.size,
      fallback_used: fallback.present?
    }

    @questionnaire_result_activity = nil
    result_id = params[:result_activity_id].to_i
    if result_id.positive? && Current.user&.lead.present?
      @questionnaire_result_activity = Current.user.lead.activities.find_by(id: result_id, taxbranch_id: @taxbranch.id)
    end
  end

  def questionnaire_source_file_exists?(source)
    normalized = source.to_s.sub(%r{\A/+}, "")
    return false if normalized.blank?
    return false unless normalized.start_with?("config/data/questionnaires/")
    return false unless normalized.match?(/\.ya?ml\z/i)

    File.exist?(Rails.root.join(normalized))
  end

  def load_questionnaire_fallback_data
    files = Dir.glob(Rails.root.join("config/data/questionnaires/*.{yml,yaml}")).sort
    return nil if files.empty?

    candidates = []
    tokens = [
      @taxbranch.slug.to_s.split("/").last,
      @taxbranch.slug_label.to_s,
      @post.slug.to_s
    ].map { |v| normalize_questionnaire_token(v) }.reject(&:blank?).uniq

    files.each do |path|
      begin
        data = YAML.safe_load_file(path, permitted_classes: [], aliases: false) || {}
      rescue Psych::Exception
        next
      end
      next unless data.is_a?(Hash)

      questions = Array(data["questions"] || data["domande"])
      next if questions.blank?

      basename = File.basename(path, ".*")
      slug_token = normalize_questionnaire_token(data["slug"])
      title_token = normalize_questionnaire_token(data["title"])
      file_token = normalize_questionnaire_token(basename)
      match_score = tokens.sum do |t|
        [
          (slug_token == t ? 3 : 0),
          (file_token == t ? 2 : 0),
          (title_token == t ? 1 : 0),
          (slug_token.include?(t) || t.include?(slug_token) ? 1 : 0),
          (file_token.include?(t) || t.include?(file_token) ? 1 : 0)
        ].max
      end

      candidates << { path: path, data: data, score: match_score }
    end

    chosen =
      if candidates.size == 1
        candidates.first
      else
        candidates.sort_by { |row| [-row[:score], row[:path]] }.first
      end
    return nil if chosen.blank?

    rel = Pathname.new(chosen[:path]).relative_path_from(Rails.root).to_s
    {
      source: rel,
      path: chosen[:path],
      data: chosen[:data],
      version: chosen[:data]["version"].to_s.presence
    }
  end

  def normalize_questionnaire_token(value)
    value.to_s.downcase
      .tr("àèéìíîòóùú", "aeeiiioouu")
      .gsub(/[^a-z0-9]+/, "_")
      .gsub(/\A_+|_+\z/, "")
  end

  def extract_questionnaire_questions(data)
    return [] unless data.is_a?(Hash)

    value = questionnaire_hash_value(data, "questions")
    value = questionnaire_hash_value(data, "domande") if value.blank?
    Array(value)
  end

  def questionnaire_hash_value(hash, key)
    return nil unless hash.is_a?(Hash)

    hash[key] || hash[key.to_sym]
  end

  def submitted_questionnaire_answers
    raw = params[:answers]
    parsed = case raw
    when ActionController::Parameters
      raw.to_unsafe_h
    when Hash
      raw
    else
      {}
    end

    parsed.to_h.each_with_object({}) do |(key, value), memo|
      next if key.to_s.strip.blank?
      next if value.to_s.strip.blank?

      memo[key.to_s] = value
    end
  end

  def missing_required_questionnaire_answers(questionnaire_taxbranch, answers)
    data = questionnaire_taxbranch.questionnaire_definition
    questions = extract_questionnaire_questions(data).sort_by { |q| questionnaire_hash_value(q, "position").to_i }
    return [] if questions.blank?

    normalized = answers.to_h.stringify_keys
    questions.each_with_object([]) do |question, acc|
      code = questionnaire_hash_value(question, "code").to_s.presence
      next if code.blank?
      next unless questionnaire_question_visible?(question, normalized)

      required_flag = questionnaire_hash_value(question, "required")
      required = required_flag.nil? ? true : required_flag == true
      next unless required

      value = normalized[code]
      blank_value =
        if value.is_a?(Array)
          value.reject { |v| v.to_s.strip.blank? }.empty?
        else
          value.to_s.strip.blank?
        end
      acc << code if blank_value
    end
  end

  def questionnaire_question_position(questionnaire_taxbranch, code)
    data = questionnaire_taxbranch.questionnaire_definition
    questions = extract_questionnaire_questions(data).sort_by { |q| questionnaire_hash_value(q, "position").to_i }
    idx = questions.index { |q| questionnaire_hash_value(q, "code").to_s == code.to_s }
    idx.present? ? (idx + 1) : 1
  end

  def questionnaire_question_visible?(question, answers)
    show_if = questionnaire_hash_value(question, "show_if")
    return true if show_if.blank?

    condition_match = lambda do |condition|
      next true unless condition.is_a?(Hash)

      source_code = questionnaire_hash_value(condition, "question").to_s
      operator = questionnaire_hash_value(condition, "operator").to_s.presence || "eq"
      expected = condition.key?("value") ? condition["value"] : condition[:value]
      actual = answers[source_code]
      actual = actual.is_a?(Array) ? actual.map(&:to_s) : actual.to_s

      case operator
      when "eq" then actual == expected.to_s
      when "neq" then actual != expected.to_s
      when "in" then Array(expected).map(&:to_s).include?(actual.to_s)
      when "not_in" then !Array(expected).map(&:to_s).include?(actual.to_s)
      when "present" then actual.present?
      when "blank" then actual.blank?
      else true
      end
    end

    if show_if.is_a?(Hash)
      all_rules = questionnaire_hash_value(show_if, "all")
      any_rules = questionnaire_hash_value(show_if, "any")
      if all_rules.present?
        Array(all_rules).all? { |rule| condition_match.call(rule) }
      elsif any_rules.present?
        Array(any_rules).any? { |rule| condition_match.call(rule) }
      else
        condition_match.call(show_if)
      end
    elsif show_if.is_a?(Array)
      show_if.all? { |rule| condition_match.call(rule) }
    else
      true
    end
  end

  def sync_questionnaire_meta_from_fallback!(fallback)
    return if fallback.blank?
    return unless @taxbranch&.slug_category.to_s == "questionnaire"

    source = fallback[:source].to_s.strip
    version = fallback[:version].to_s.strip
    return if source.blank?

    meta_hash = @taxbranch.meta.is_a?(Hash) ? @taxbranch.meta.deep_dup : {}
    changed = false

    if meta_hash["questionnaire_source"].to_s != source
      meta_hash["questionnaire_source"] = source
      changed = true
    end

    if version.present? && meta_hash["questionnaire_version"].to_s != version
      meta_hash["questionnaire_version"] = version
      changed = true
    end

    return unless changed

    @taxbranch.update_columns(meta: meta_hash, updated_at: Time.current)
    @taxbranch.meta = meta_hash
  rescue StandardError => e
    Rails.logger.warn("Questionnaire fallback sync skipped for taxbranch ##{@taxbranch&.id}: #{e.class} #{e.message}")
  end

  def post_params
    # niente più :status e :published_at qui, perché vivono su Taxbranch
    params.expect(post: [
      :lead_id,
      :title,
      :slug,
      :description,
      :thumb_url,
      :horizontal_cover_url,
      :vertical_cover_url,
      :banner_url,
      :content,
      :content_md,
      :taxbranch_id,
      :mermaid,
      :meta,
      :url_media_content
    ])
  end

  def sort_column
    case params[:sort]
    when "title"        then "title"
    when "status"       then "status"
    when "published_at" then "published_at"
    when "created_at"   then "created_at"
    when "tax"          then "tax"
    else "published_at"
    end
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def set_superadmin
    redirect_to root_path, alert: "Accesso non autorizzato." unless Current.user&.superadmin?
  end
end
