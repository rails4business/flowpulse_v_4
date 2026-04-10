class DashboardController < ApplicationController
  def home
    @lead = Current.user&.lead
    return redirect_to root_path, alert: "No lead found" unless @lead
    if superadmin_dashboard_mode_active?
      redirect_to dashboard_superadmin_path(request.query_parameters.except(:tab))
      return
    end

    if params[:month].present? && params[:year].present? && params[:date].blank?
      day = params[:day].to_i
      day = 1 if day < 1
      base = Date.new(params[:year].to_i, params[:month].to_i, 1)
      date = Date.new(base.year, base.month, [day, base.end_of_month.day].min)
      redirect_to dashboard_home_path(date: date.strftime("%Y-%m-%d")) and return
    end

    @selected_date = begin
      if params[:month].present? && params[:year].present?
        Date.new(params[:year].to_i, params[:month].to_i, 1)
      elsif params[:date].present?
        date_param = params[:date]
        if date_param.is_a?(ActionController::Parameters) || date_param.is_a?(Hash)
          Date.new(date_param[:year].to_i, date_param[:month].to_i, date_param[:day].to_i)
        else
          Date.parse(date_param.to_s)
        end
      elsif params[:on].present?
        Date.parse(params[:on])
      end
    rescue ArgumentError
      nil
    end
    @selected_date ||= Time.zone.today

    base_scope = Eventdate.where(lead: @lead).order(date_start: :asc)
    @day_events = base_scope.where(date_start: @selected_date.beginning_of_day..@selected_date.end_of_day)
    @today = Time.zone.today
    @today_week_events_count = base_scope.where(
      date_start: @today.beginning_of_week..@today.end_of_week
    ).count

    month_start = @selected_date.beginning_of_month.beginning_of_week(:monday)
    month_end = @selected_date.end_of_month.end_of_week(:monday)
    @event_counts_by_day = base_scope
      .reorder(nil)
      .where(date_start: month_start.beginning_of_day..month_end.end_of_day)
      .group("DATE(date_start)")
      .count

    requested_tab = params[:tab].presence_in(%w[academy activity diario_salute corsi bookings enrollments]) || "academy"
    @tab = requested_tab
    @current_domain = Current.domain
    @lead_domains = @lead.active_domains
    @domain_membership =
      if @current_domain.present?
        @lead.domain_memberships.find_by(domain_id: @current_domain.id)
      end
    @domain_role_options = available_domain_role_options(@domain_membership)
    mycontact_ids = @lead.mycontacts.select(:id)
    @bookings = Booking.includes(:eventdate, :service, :commitment, :enrollment)
                       .where(mycontact_id: mycontact_ids)
                       .order(created_at: :desc)
                       .limit(20)
    @enrollments = @lead.enrollments.includes(:service, :journey)
                          .order(updated_at: :desc)
                          .limit(20)
    questionnaire_scope = Activity.questionnaires.where(lead: @lead)
    questionnaire_scope = questionnaire_scope.where(domain_id: @current_domain.id) if @current_domain.present?
    @latest_questionnaire_activity = questionnaire_scope.recent_first.first
    activity_feed_scope = Activity.includes(:certificate, :eventdate, :booking, :enrollment, taxbranch: :post).where(lead: @lead)
    activity_feed_scope = activity_feed_scope.where(domain_id: [@current_domain.id, nil]) if @current_domain.present?
    @activity_feed_items = activity_feed_scope
      .order(occurred_at: :desc, id: :desc)
      .limit(60)
      .map { |activity| build_activity_feed_item(activity) }
    build_academy_todo_from_taxbranch!
    load_dashboard_activity_modal!

    @dashboard_tab_steps = %w[academy activity diario_salute corsi bookings enrollments]
    first_step_completed = @academy_first_root_step_completed == true
    @dashboard_tab_unlocks = @dashboard_tab_steps.index_with { |key| %w[academy activity].include?(key) || first_step_completed }

    if @dashboard_tab_unlocks[@tab] == false
      redirect_to dashboard_home_path(tab: "academy"), alert: "Completa il primo step Academy prima di proseguire ai tab successivi."
      return
    end
  end

  def superadmin
    unless superadmin_dashboard_mode_active?
      redirect_to dashboard_home_path(tab: params[:tab].presence || "academy"), alert: "Attiva la modalità superadmin per accedere a questa dashboard."
      return
    end
  end

  def calendarweekplan
    unless superadmin_dashboard_mode_active?
      redirect_to dashboard_home_path(tab: params[:tab].presence || "academy"), alert: "Attiva la modalità superadmin per accedere a questa dashboard."
      return
    end
  end

  def liste
  end

  def create_domain_membership
    lead = Current.user&.lead
    domain = Current.domain

    if lead.blank? || domain.blank?
      redirect_to dashboard_home_path, alert: "Impossibile creare la membership: lead o dominio non disponibili."
      return
    end

    membership = lead.domain_memberships.find_or_initialize_by(domain: domain)

    if membership.new_record?
      membership.status = :active
      membership.domain_active_role = membership.domain_active_role.presence || "member"
      has_primary = lead.domain_memberships.where(primary: true).where.not(id: membership.id).exists?
      membership.primary = !has_primary if membership.primary.nil?
      membership.save!
      notice = "Domain membership creata."
    else
      notice = "Domain membership già presente."
    end

    redirect_to dashboard_home_path, notice: notice
  rescue ActiveRecord::RecordInvalid => e
    redirect_to dashboard_home_path, alert: e.message
  end

  def update_domain_active_role
    lead = Current.user&.lead
    domain = Current.domain
    membership = if lead.present? && domain.present?
      lead.domain_memberships.find_by(domain_id: domain.id)
    end

    if membership.blank?
      redirect_to dashboard_home_path, alert: "Membership dominio non trovata."
      return
    end

    requested_role = params[:domain_active_role].to_s.strip
    allowed_roles = available_domain_role_options(membership)
    unless allowed_roles.include?(requested_role)
      redirect_to dashboard_home_path, alert: "Ruolo non valido per questo dominio."
      return
    end

    user_is_superadmin = Current.user.respond_to?(:superadmin?) && Current.user.superadmin?
    if requested_role.casecmp("superadmin").zero? && !user_is_superadmin
      redirect_to dashboard_home_path(tab: params[:tab].presence || "academy"), alert: "Ruolo superadmin non disponibile per questo utente."
      return
    end

    ActiveRecord::Base.transaction do
      membership.update!(domain_active_role: requested_role)
      if user_is_superadmin
        Current.user.update!(superadmin_mode_active: requested_role.casecmp("superadmin").zero?)
      end
    end

    redirect_to dashboard_home_path(tab: params[:tab].presence || "academy"), notice: "Ruolo attivo aggiornato."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to dashboard_home_path, alert: e.message
  end

  private

  def superadmin_dashboard_mode_active?
    Current.user&.superadmin? && Current.user&.superadmin_mode_active?
  end

  def available_domain_role_options(membership)
    is_user_superadmin = Current.user.respond_to?(:superadmin?) && Current.user.superadmin?
    return is_user_superadmin ? [ "member", "superadmin" ] : [ "member" ] if membership.blank?

    cert_scope = membership.certificates
    roles = cert_scope.pluck(:role_name).filter_map { |r| r.to_s.strip.presence }
    roles = roles.reject { |role_name| role_name.casecmp("superadmin").zero? } unless is_user_superadmin
    base_roles = [ "member" ]
    base_roles << "superadmin" if is_user_superadmin
    current_active_role = membership.domain_active_role.to_s.strip.presence
    (base_roles + roles + [ current_active_role ]).compact.uniq
  end

  def build_academy_todo_from_taxbranch!
    @academy_todo_enabled = false
    @academy_requires_membership = true
    @academy_root_taxbranch = Taxbranch.find_by(slug: "academy/posturacorretta")
    return if @academy_root_taxbranch.blank?
    @academy_requires_membership = @domain_membership.blank?

    mycontact_ids = @lead.mycontacts.select(:id)
    bookings = Booking.includes(:service, :eventdate, :enrollment, :commitment)
                      .where(mycontact_id: mycontact_ids).to_a
    enrollments = @lead.enrollments.includes(:service, :journey).to_a
    certificates = @lead.certificates.includes(:service, :journey, :taxbranch).to_a
    journeys = @lead.journeys.includes(:taxbranch, :service).to_a
    eventdates = Eventdate.includes(:journey, :taxbranch).where(lead: @lead).to_a

    step_scope = @academy_root_taxbranch.children.includes(:post).ordered
    step_scope = step_scope.reorder(position: :desc) if @academy_root_taxbranch.order_des?
    trackable_step_ids = step_scope.flat_map { |step| [ step.id ] + step.descendants.pluck(:id) }.uniq
    activity_scope = Activity.where(lead: @lead, kind: %w[step_completed questionnaire_submission])
    # Include legacy activities with nil domain_id so completion is still detected.
    activity_scope = activity_scope.where(domain_id: [@current_domain.id, nil]) if @current_domain.present?
    completed_step_ids = if trackable_step_ids.any?
      activity_scope.where(taxbranch_id: trackable_step_ids, status: "archived").distinct.pluck(:taxbranch_id)
    else
      []
    end
    step_activities = if trackable_step_ids.any?
      scoped = Activity.includes(:certificate)
                       .where(lead: @lead, taxbranch_id: trackable_step_ids)
                       .order(occurred_at: :desc, id: :desc)
      @current_domain.present? ? scoped.where(domain_id: [@current_domain.id, nil]).to_a : scoped.to_a
    else
      []
    end

    @academy_steps = step_scope.map do |step|
      build_academy_step_node(
        step: step,
        bookings: bookings,
        enrollments: enrollments,
        certificates: certificates,
        journeys: journeys,
        eventdates: eventdates,
        activities: step_activities,
        completed_step_ids: completed_step_ids
      )
    end

    @academy_completed_steps_count = @academy_steps.count { |item| item[:status_key] == :completed }
    @academy_total_steps_count = @academy_steps.size
    @academy_progress_percent =
      if @academy_total_steps_count.positive?
        ((@academy_completed_steps_count.to_f / @academy_total_steps_count) * 100).round
      else
        0
      end
    @academy_next_step = @academy_steps.find { |item| item[:status_key] == :todo } || @academy_steps.find { |item| item[:status_key] == :scheduled }
    @academy_todo_enabled = @academy_steps.any?
    build_academy_dashboard_sections!
  end

  def build_academy_dashboard_sections!
    steps = Array(@academy_steps)
    @academy_first_root_step = steps.first
    @academy_first_root_step_completed = @academy_first_root_step.present? && @academy_first_root_step[:status_key] == :completed
    @academy_visible_root_step = steps.find { |step| step[:status_key] != :completed } || @academy_first_root_step
    @academy_completed_root_steps = sort_completed_steps_desc(steps.select { |step| step[:status_key] == :completed })

    active_root = @academy_visible_root_step
    active_root_category = active_root&.dig(:taxbranch)&.slug_category.to_s
    @academy_active_root_category = active_root_category

    @academy_inscription_focus_step = nil
    @academy_inscription_completed_steps = []
    @academy_path_modules = []
    @academy_current_action_step = nil

    if active_root_category == "academy_inscription"
      inscription_children = Array(active_root[:children])
      @academy_inscription_focus_step = inscription_children.find { |step| step[:status_key] != :completed } || inscription_children.first
      @academy_inscription_completed_steps = sort_completed_steps_desc(inscription_children.select { |step| step[:status_key] == :completed })
      @academy_current_action_step = @academy_inscription_focus_step
    elsif active_root_category == "academy_path"
      module_nodes = []
      collect_module_nodes!(active_root, module_nodes)
      active_root_id = active_root&.dig(:taxbranch)&.id
      @academy_path_modules = module_nodes
        .uniq { |node| node[:taxbranch]&.id || node[:title] }
        .reject { |node| active_root_id.present? && node[:taxbranch]&.id == active_root_id }
      @academy_current_action_step = @academy_path_modules.find { |step| step[:status_key] != :completed } || @academy_path_modules.first
    end

    @academy_next_step = @academy_current_action_step || @academy_visible_root_step || @academy_next_step
  end

  def sort_completed_steps_desc(steps)
    Array(steps).sort_by do |step|
      ts = step[:completed_activity_occurred_at].presence || step[:activity_occurred_at].presence || step[:next_at].presence
      ts || Time.at(0)
    end.reverse
  end

  def collect_module_nodes!(node, acc)
    return if node.blank?

    acc << node if node[:is_module_academy]
    Array(node[:children]).each { |child| collect_module_nodes!(child, acc) }
  end

  def related_records_for_step(step:, bookings:, enrollments:, certificates:, journeys:, eventdates:, activities:)
    step_taxbranch_id = step.id
    matcher = lambda do |tb_id, text|
      tb_id.to_i == step_taxbranch_id || text.to_s.include?(step.slug_label.to_s.parameterize)
    end

    related_bookings = bookings.select do |booking|
      matcher.call(booking.service&.taxbranch_id, booking.service&.slug) ||
        matcher.call(booking.eventdate&.taxbranch_id, booking.eventdate&.description) ||
        matcher.call(booking.commitment&.taxbranch_id, booking.commitment&.role_name) ||
        matcher.call(booking.enrollment&.taxbranch&.id, booking.enrollment&.service&.slug)
    end

    related_enrollments = enrollments.select do |enrollment|
      matcher.call(enrollment.service&.taxbranch_id, enrollment.service&.slug) ||
        matcher.call(enrollment.journey&.taxbranch_id, enrollment.journey&.slug)
    end

    related_certificates = certificates.select do |certificate|
      matcher.call(certificate.taxbranch_id, certificate.role_name) ||
        matcher.call(certificate.service&.taxbranch_id, certificate.service&.slug) ||
        matcher.call(certificate.journey&.taxbranch_id, certificate.journey&.slug)
    end

    related_journeys = journeys.select do |journey|
      matcher.call(journey.taxbranch_id, journey.slug) ||
        matcher.call(journey.service&.taxbranch_id, journey.service&.slug)
    end

    related_eventdates = eventdates.select do |eventdate|
      matcher.call(eventdate.taxbranch_id, eventdate.description) ||
        matcher.call(eventdate.journey&.taxbranch_id, eventdate.journey&.slug)
    end
    related_activities = activities.select { |activity| activity.taxbranch_id.to_i == step_taxbranch_id }

    {
      bookings: related_bookings,
      enrollments: related_enrollments,
      certificates: related_certificates,
      journeys: related_journeys,
      eventdates: related_eventdates,
      activities: related_activities
    }
  end

  def build_academy_step_node(step:, bookings:, enrollments:, certificates:, journeys:, eventdates:, activities:, completed_step_ids:)
    related = related_records_for_step(
      step: step,
      bookings: bookings,
      enrollments: enrollments,
      certificates: certificates,
      journeys: journeys,
      eventdates: eventdates,
      activities: activities
    )

    latest_activity = related[:activities].first
    latest_completed_activity = related[:activities].find { |activity| activity.status.to_s == "archived" }
    status_key = if completed_step_ids.include?(step.id)
      :completed
    else
      resolve_step_status_key(related, allow_completed: false)
    end
    status_key = :todo if @academy_requires_membership

    child_scope = step.children.includes(:post).ordered
    child_scope = child_scope.reorder(position: :desc) if step.order_des?
    children = child_scope.map do |child|
      build_academy_step_node(
        step: child,
        bookings: bookings,
        enrollments: enrollments,
        certificates: certificates,
        journeys: journeys,
        eventdates: eventdates,
        activities: activities,
        completed_step_ids: completed_step_ids
      )
    end

    children_total = children.size
    children_completed = children.count { |child| child[:status_key] == :completed }
    children_progress_percent =
      if children_total.positive?
        ((children_completed.to_f / children_total) * 100).round
      else
        0
      end

    step_progress_total = children_total.positive? ? children_total : 1
    step_progress_completed = children_total.positive? ? children_completed : (status_key == :completed ? 1 : 0)
    step_progress_percent =
      if step_progress_total.positive?
        ((step_progress_completed.to_f / step_progress_total) * 100).round
      else
        0
      end

    delivery = resolve_delivery_details(related)

    raw_description = step.post&.description.to_s
    {
      taxbranch: step,
      title: step.post&.title.presence || step.slug_label,
      subtitle: raw_description.truncate(120).presence || step.slug,
      status_key: status_key,
      status_label: status_label_for(status_key),
      activity_status: latest_activity&.status,
      activity_status_label: activity_status_label_for(latest_activity),
      activity_occurred_at: latest_completed_activity&.occurred_at || latest_activity&.occurred_at,
      latest_activity_id: latest_activity&.id,
      completed_activity_id: latest_completed_activity&.id,
      completed_activity_occurred_at: latest_completed_activity&.occurred_at,
      mode_label: @academy_requires_membership ? "accedi all'accademia" : resolve_mode_label(related),
      delivery_available: delivery[:available],
      delivery_mode: delivery[:mode],
      delivery_has_professional: delivery[:has_professional],
      delivery_person_label: delivery[:person_label],
      delivery_instructor_name: delivery[:instructor_name],
      delivery_instructor_role: delivery[:instructor_role],
      delivery_channel: delivery[:channel],
      delivery_format: delivery[:format],
      delivery_location: delivery[:location],
      link_post: step.post,
      next_at: extract_step_datetime(related),
      children: children,
      is_module_academy: %w[academy_module module_academy module_accademy].include?(step.slug_category.to_s),
      module_total_steps: children_total,
      module_completed_steps: children_completed,
      module_progress_percent: children_progress_percent,
      step_progress_total: step_progress_total,
      step_progress_completed: step_progress_completed,
      step_progress_percent: step_progress_percent,
      children_progress_total: children_total,
      children_progress_completed: children_completed,
      children_progress_percent: children_progress_percent
    }
  end

  def extract_step_datetime(related)
    timestamps = []
    timestamps.concat(Array(related[:eventdates]).map(&:date_start))
    timestamps.concat(Array(related[:bookings]).map { |b| b.eventdate&.date_start })
    timestamps.compact.min
  end

  def resolve_step_status_key(related, allow_completed: true)
    latest_activity = related[:activities].first
    if latest_activity.present?
      return :completed if latest_activity.status.to_s == "archived"
      return :in_progress if %w[recorded reviewed].include?(latest_activity.status.to_s)
    end

    completed_booking = related[:bookings].any? { |b| b.completed? || b.checked_in? }
    completed_enrollment = related[:enrollments].any?(&:completed?)
    completed_eventdate = related[:eventdates].any?(&:completed?)
    if allow_completed
      return :completed if related[:certificates].any? || completed_booking || completed_enrollment || completed_eventdate
    end

    scheduled_booking = related[:bookings].any? { |b| b.confirmed? || b.pending_confirmation? || b.requested? }
    scheduled_eventdate = related[:eventdates].any? { |e| e.date_start.present? && e.date_start > Time.current }
    return :scheduled if scheduled_booking || scheduled_eventdate

    in_progress_enrollment = related[:enrollments].any? { |e| e.confirmed? || e.pending_confirmation? || e.requested? || e.draft? }
    in_progress_journey = related[:journeys].any? { |j| !j.journeys_status_chiuso? }
    return :in_progress if in_progress_enrollment || in_progress_journey

    :todo
  end

  def activity_status_label_for(activity)
    return nil if activity.blank?

    case activity.status.to_s
    when "recorded" then "Registrata"
    when "reviewed" then "In revisione"
    when "archived" then "Completata"
    else activity.status.to_s.humanize
    end
  end

  def resolve_mode_label(related)
    latest_activity = related[:activities].first
    if latest_activity.present?
      mode = latest_activity.attributes["mode"].to_s
      return "in autonomia" if mode == "autonomia"
      return "con professionista" if mode == "professionista"
    end

    booking = related[:bookings].first
    if booking.present?
      name = booking.service&.name.to_s.downcase
      return "con tutor" if name.include?("tutor")
      return "con professionista" if booking.participant_role_professionista? || name.include?("profession")
      return "in autonomia" if booking.mode_autonomia?
    end

    enrollment = related[:enrollments].first
    if enrollment.present?
      name = enrollment.service&.name.to_s.downcase
      return "in autonomia" if enrollment.mode_autonomia?
      return "con tutor" if name.include?("tutor")
      return "con professionista"
    end

    return "con professionista" if related[:certificates].any?

    "da definire"
  end

  def resolve_delivery_details(related)
    activity = related[:activities].first
    return default_delivery_details if activity.blank?

    has_professional = activity.certificate_id.present?
    mode = activity.attributes["mode"].to_s.presence
    mode = has_professional ? "professionista" : "autonomia" if mode.blank?
    mode = "autonomia" unless has_professional
    channel = activity.attributes["channel"].to_s.presence
    format = activity.attributes["format"].to_s.presence
    location_type = activity.attributes["location_type"].to_s.presence
    location_name = activity.attributes["location_name"].to_s.presence
    location_address = activity.attributes["location_address"].to_s.presence

    location_label = if channel == "online"
      "Online"
    elsif location_name.present?
      location_name
    elsif location_type == "domicilio"
      "A domicilio"
    elsif location_type == "centro"
      "In Centro"
    elsif location_address.present?
      location_address
    else
      "In Centro"
    end

    instructor_name = if !has_professional || mode == "autonomia"
      "In autonomia"
    else
      "Da definire"
    end

    instructor_role = if !has_professional || mode == "autonomia"
      "Percorso personale"
    else
      activity.certificate&.role_name.to_s.presence || "Professionista"
    end

    format_label = case format
    when "gruppo"
      size = activity.attributes["group_size"].to_i
      size.positive? ? "Gruppo #{size}" : "Gruppo"
    when "singolo"
      "Singolo"
    else
      "Gruppo 8-12"
    end
    format_label = "Singolo" if mode == "autonomia"

    {
      available: true,
      mode: mode,
      has_professional: has_professional,
      person_label: has_professional ? "Insegnante" : "Modalita",
      instructor_name: instructor_name,
      instructor_role: instructor_role,
      channel: channel.presence || "offline",
      format: format_label,
      location: location_label
    }
  end

  def default_delivery_details
    {
      available: false,
      mode: nil,
      has_professional: false,
      person_label: nil,
      instructor_name: nil,
      instructor_role: nil,
      channel: nil,
      format: nil,
      location: nil
    }
  end

  def status_label_for(status_key)
    case status_key
    when :completed then "Completato"
    when :scheduled then "Pianificato"
    when :in_progress then "In corso"
    else "Da fare"
    end
  end

  def load_dashboard_activity_modal!
    @open_activity_modal = false
    @modal_questionnaire_mode = false
    @modal_read_only = false
    return unless params[:open_activity_modal].to_s == "1"

    @modal_activity = @lead.activities.find_by(id: params[:activity_id])
    return if @modal_activity.blank?

    @modal_post = begin
      Post.includes(:taxbranch).friendly.find(params[:post_id])
    rescue StandardError
      nil
    end
    return if @modal_post.blank?
    return if @modal_activity.taxbranch_id != @modal_post.taxbranch_id

    tb = @modal_post.taxbranch
    @modal_is_questionnaire = tb&.questionnaire_source_path.present? || tb&.questionnaire_root?
    @modal_read_only = params[:readonly].to_s == "1" || @modal_activity.status.to_s == "archived"
    build_modal_questionnaire_state!(tb) if @modal_is_questionnaire
    @open_activity_modal = true
  end

  def build_modal_questionnaire_state!(taxbranch)
    data = taxbranch.questionnaire_definition
    raw_questions = questionnaire_hash_value(data, "questions") || questionnaire_hash_value(data, "domande") || []
    questions = Array(raw_questions).sort_by { |q| questionnaire_hash_value(q, "position").to_i }
    payload_hash = @modal_activity&.payload.is_a?(Hash) ? @modal_activity.payload : {}
    persisted_answers = normalize_modal_answers(payload_hash["answers"])
    live_answers = normalize_modal_answers(params[:answers])
    answers = persisted_answers.merge(live_answers)
    persist_modal_questionnaire_answers!(answers) if live_answers.present? && !@modal_read_only
    visible_questions = questions.select { |q| modal_question_visible?(q, answers) }
    return if visible_questions.blank?

    completion_step = visible_questions.size + 1
    step = params[:q].to_i
    step = 1 if step <= 0
    step = completion_step if step > completion_step
    completion_screen = step == completion_step
    current_question = completion_screen ? visible_questions.last : visible_questions[step - 1]
    current_code = completion_screen ? nil : (questionnaire_hash_value(current_question, "code").presence || "q_#{step}").to_s

    @modal_questionnaire_mode = true
    @modal_questionnaire_answers = answers
    @modal_questionnaire_visible_questions = visible_questions
    @modal_questionnaire_step = step
    @modal_questionnaire_count = visible_questions.size
    @modal_questionnaire_completion_screen = completion_screen
    @modal_questionnaire_current_question = current_question
    @modal_questionnaire_current_code = current_code
    @modal_questionnaire_current_answer = current_code.present? ? answers[current_code].to_s : nil
    @modal_questionnaire_progress_percent = completion_screen ? 100 : ((step.to_f / visible_questions.size) * 100).round
  end

  def persist_modal_questionnaire_answers!(answers)
    return if @modal_activity.blank?

    payload = @modal_activity.payload.is_a?(Hash) ? @modal_activity.payload.deep_dup : {}
    payload["answers"] = answers
    payload["questionnaire_post_slug"] = @modal_post&.slug
    payload["draft_saved_at"] = Time.current.iso8601

    @modal_activity.update(payload: payload)
  rescue StandardError
    nil
  end

  def normalize_modal_answers(raw_answers)
    hash =
      if raw_answers.respond_to?(:to_unsafe_h)
        raw_answers.to_unsafe_h
      elsif raw_answers.is_a?(Hash)
        raw_answers
      else
        {}
      end

    hash.to_h.stringify_keys.transform_values do |value|
      value.is_a?(Array) ? value.map(&:to_s) : value.to_s
    end
  end

  def modal_question_visible?(question, answers)
    show_if = questionnaire_hash_value(question, "show_if")
    return true if show_if.blank?

    if show_if.is_a?(Hash)
      all_rules = questionnaire_hash_value(show_if, "all")
      any_rules = questionnaire_hash_value(show_if, "any")
      if all_rules.present?
        Array(all_rules).all? { |rule| modal_condition_match?(rule, answers) }
      elsif any_rules.present?
        Array(any_rules).any? { |rule| modal_condition_match?(rule, answers) }
      else
        modal_condition_match?(show_if, answers)
      end
    elsif show_if.is_a?(Array)
      show_if.all? { |rule| modal_condition_match?(rule, answers) }
    else
      true
    end
  end

  def modal_condition_match?(condition, answers)
    return true unless condition.is_a?(Hash)

    source_code = questionnaire_hash_value(condition, "question").to_s
    operator = questionnaire_hash_value(condition, "operator").to_s.presence || "eq"
    expected = condition.key?("value") ? condition["value"] : condition[:value]
    actual = answers[source_code]
    actual = actual.is_a?(Array) ? actual.map(&:to_s) : actual.to_s

    case operator
    when "eq"
      actual == expected.to_s
    when "neq"
      actual != expected.to_s
    when "in"
      Array(expected).map(&:to_s).include?(actual.to_s)
    when "not_in"
      !Array(expected).map(&:to_s).include?(actual.to_s)
    when "present"
      actual.present?
    when "blank"
      actual.blank?
    else
      true
    end
  end

  def questionnaire_hash_value(data, key)
    return nil unless data.is_a?(Hash)

    data[key] || data[key.to_s] || data[key.to_sym]
  end

  def build_activity_feed_item(activity)
    taxbranch = activity.taxbranch
    post = taxbranch&.post
    related = {
      bookings: [],
      enrollments: [],
      certificates: [],
      journeys: [],
      eventdates: activity.eventdate.present? ? [activity.eventdate] : [],
      activities: [activity]
    }
    delivery = resolve_delivery_details(related)
    subtitle_source = activity.source_ref.presence || taxbranch&.slug

    {
      activity: activity,
      taxbranch: taxbranch,
      post: post,
      title: post&.title.presence || taxbranch&.slug_label.to_s.presence || "Activity ##{activity.id}",
      subtitle: subtitle_source.to_s.truncate(120),
      status_key: activity.status.to_s == "archived" ? :completed : :in_progress,
      status_label: activity_status_label_for(activity),
      activity_occurred_at: activity.occurred_at,
      mode_label: resolve_mode_label(related),
      delivery_mode: delivery[:mode],
      delivery_has_professional: delivery[:has_professional],
      delivery_person_label: delivery[:person_label],
      delivery_instructor_name: delivery[:instructor_name],
      delivery_instructor_role: delivery[:instructor_role],
      delivery_channel: delivery[:channel],
      delivery_format: delivery[:format],
      delivery_location: delivery[:location],
      eventdate: activity.eventdate,
      booking: activity.booking,
      enrollment: activity.enrollment
    }
  end
end
