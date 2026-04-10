class DatacontactsController < ApplicationController
  before_action :set_datacontact, only: %i[ show edit update destroy ]
  before_action :set_reference_data, only: %i[ new edit create update ]

  # GET /contacts or /contacts.json
  def index
    @datacontacts = Datacontact.order(:last_name, :first_name)
  end

  # GET /contacts/1 or /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @datacontact = Datacontact.new(
      lead: Current.user&.lead,
      referent_lead: Current.user&.lead
    )
    apply_profile_defaults(@datacontact)
  end

  # GET /contacts/1/edit
  def edit
    apply_profile_defaults(@datacontact)
  end

  # POST /contacts or /contacts.json
  def create
    @datacontact = Datacontact.new(persisted_datacontact_params)
    @datacontact.lead ||= Current.user&.lead
    @datacontact.referent_lead ||= Current.user&.lead
    apply_virtual_datacontact_attributes(@datacontact)

    respond_to do |format|
      if @datacontact.save
        finalize_step_activity_if_needed!(@datacontact) unless wizard_next_step?
        format.html { redirect_to datacontact_success_path(@datacontact), notice: datacontact_success_notice("create") }
        format.json { render :show, status: :created, location: @datacontact }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @datacontact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1 or /contacts/1.json
  def update
    respond_to do |format|
      @datacontact.assign_attributes(persisted_datacontact_params)
      apply_virtual_datacontact_attributes(@datacontact)

      if @datacontact.save
        finalize_step_activity_if_needed!(@datacontact) unless wizard_next_step?
        format.html { redirect_to datacontact_success_path(@datacontact), notice: datacontact_success_notice("update"), status: :see_other }
        format.json { render :show, status: :ok, location: @datacontact }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @datacontact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1 or /contacts/1.json
  def destroy
    @datacontact.destroy!

    respond_to do |format|
      format.html { redirect_to datacontacts_path, notice: "I dati contatto sono stati eliminati.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_datacontact
      @datacontact = Datacontact.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def datacontact_params
      params.require(:datacontact)
            .permit(
              :first_name,
              :last_name,
              :lead_id,
              :email,
              :phone,
              :city,
              :province,
              :date_of_birth,
              :place_of_birth,
              :fiscal_code,
              :vat_number,
              :billing_name,
              :billing_address,
              :billing_zip,
              :billing_city,
              :billing_country,
              :meta,
              :referent_lead_id,
              :socials
            )
    end

    def persisted_datacontact_params
      datacontact_params.except(:city, :province)
    end

    def apply_virtual_datacontact_attributes(datacontact)
      datacontact.city = datacontact_params[:city] if datacontact_params.key?(:city)
      datacontact.province = datacontact_params[:province] if datacontact_params.key?(:province)
    end

    def set_reference_data
      @referent_leads = Lead.order(:surname, :name)
    end

    def apply_profile_defaults(datacontact)
      return if datacontact.blank?

      datacontact.email ||= Current.user&.email_address
    end

    def datacontact_success_path(datacontact)
      if wizard_next_step?
        return datacontact_wizard_path(datacontact, wizard_step_param + 1)
      end

      params[:return_to].presence || datacontact_path(datacontact)
    end

    def datacontact_wizard_path(datacontact, step_index)
      route_params = {}.tap do |hash|
        hash[:step_taxbranch_id] = params[:step_taxbranch_id] if params[:step_taxbranch_id].present?
        hash[:activity_id] = params[:activity_id] if params[:activity_id].present?
        hash[:return_to] = params[:return_to] if params[:return_to].present?
        hash[:wizard_step] = step_index.clamp(0, 3)
      end

      edit_datacontact_path(datacontact, route_params)
    end

    def wizard_next_step?
      params[:wizard_action].to_s == "next_step" && params[:step_taxbranch_id].present?
    end

    def wizard_step_param
      params[:wizard_step].to_i
    end

    def datacontact_success_notice(action)
      return "Bozza salvata." if wizard_next_step?

      action == "create" ? "I dati contatto sono stati creati correttamente." : "I dati contatto sono stati aggiornati."
    end

    def finalize_step_activity_if_needed!(datacontact)
      lead = Current.user&.lead
      return if lead.blank?

      taxbranch = Taxbranch.find_by(id: params[:step_taxbranch_id])
      return if taxbranch.blank?
      return unless completion_rule_satisfied?(taxbranch, datacontact)

      activity = if params[:activity_id].present?
        lead.activities.where(id: params[:activity_id]).find_by(taxbranch_id: taxbranch.id)
      end
      activity ||= lead.activities
                       .where(taxbranch_id: taxbranch.id, status: %w[recorded reviewed])
                       .order(occurred_at: :desc, id: :desc)
                       .first
      return if activity.blank?

      activity.update(status: "archived", occurred_at: Time.current)
    end

    def completion_rule_satisfied?(taxbranch, datacontact)
      supported_types = %w[datacontact_fields_present lead_fields_present]
      return false unless supported_types.include?(taxbranch.completion_rule_type)

      taxbranch.completion_required_fields.all? do |field|
        datacontact.public_send(field).present?
      rescue NoMethodError
        false
      end
    end
end
