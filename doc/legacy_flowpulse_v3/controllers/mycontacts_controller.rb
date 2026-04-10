class MycontactsController < ApplicationController
  before_action :ensure_lead!
  before_action :set_mycontact, only: %i[ show edit update destroy ]
  before_action :set_reference_data, only: %i[ edit update ]
  before_action :set_datacontact, only: :new_for_datacontact

  def index
    @mycontacts =
      current_lead
        .mycontacts
        .includes(:datacontact)
        .order("datacontacts.last_name NULLS LAST, datacontacts.first_name NULLS LAST")
  end

  def show; end

  def new
    @datacontact_form = Datacontact.new
  end

  def lookup
    attrs = datacontact_lookup_params
    @datacontact_form = Datacontact.new(attrs)
    ensure_lookup_requirements!(attrs)
    return if performed?

    datacontact = find_matching_datacontact(attrs)

    unless datacontact
      datacontact = build_datacontact_from(attrs)
      unless datacontact.save
        @datacontact_form = datacontact
        return render :new, status: :unprocessable_entity
      end
    end

    redirect_to new_datacontact_mycontact_path(datacontact)
  end

  def new_for_datacontact
    @mycontact =
      current_lead.mycontacts.find_or_initialize_by(datacontact: @datacontact)
    apply_defaults_for(@mycontact, @datacontact)
  end

  def edit; end

  def create
    datacontact = Datacontact.find(mycontact_params[:datacontact_id])
    @mycontact =
      current_lead.mycontacts.find_or_initialize_by(datacontact: datacontact)
    @mycontact.assign_attributes(mycontact_params.except(:datacontact_id))
    apply_defaults_for(@mycontact, datacontact)

    respond_to do |format|
      if @mycontact.save
        format.html { redirect_to mycontacts_path, notice: "Contatto collegato correttamente." }
        format.json { render :show, status: :created, location: @mycontact }
      else
        format.html do
          @datacontact = datacontact
          render :new_for_datacontact, status: :unprocessable_entity
        end
        format.json { render json: @mycontact.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @mycontact.update(mycontact_params.except(:datacontact_id))
        format.html { redirect_to @mycontact, notice: "Collegamento aggiornato.", status: :see_other }
        format.json { render :show, status: :ok, location: @mycontact }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mycontact.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @mycontact.destroy!

    respond_to do |format|
      format.html { redirect_to mycontacts_path, notice: "Collegamento rimosso.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_mycontact
    @mycontact = current_lead.mycontacts.find(params.require(:id))
  end

  def mycontact_params
    params
      .require(:mycontact)
      .permit(:datacontact_id, :status_contact, :approved_by_referent_at, :original)
  end

  def datacontact_lookup_params
    params
      .require(:datacontact)
      .permit(:first_name, :last_name, :email, :phone, :date_of_birth, :fiscal_code, :vat_number)
  end

  def find_matching_datacontact(attrs)
    email = attrs[:email].to_s.strip.downcase
    return Datacontact.where("LOWER(email) = ?", email).first if email.present?

    if attrs[:first_name].present? && attrs[:last_name].present? && attrs[:date_of_birth].present?
      Datacontact.find_by(
        first_name: attrs[:first_name],
        last_name: attrs[:last_name],
        date_of_birth: attrs[:date_of_birth]
      )
    end
  end

  def build_datacontact_from(attrs)
    Datacontact.new(attrs)
  end

  def ensure_lookup_requirements!(attrs)
    email_present = attrs[:email].present?
    identity_complete = attrs[:first_name].present? && attrs[:last_name].present? && attrs[:date_of_birth].present?

    return if email_present || identity_complete

    @datacontact_form.errors.add(:base, "Inserisci l'email oppure nome, cognome e data di nascita.")
    render :new, status: :unprocessable_entity
  end

  def apply_defaults_for(mycontact, datacontact)
    original = datacontact.lead_id.blank? || datacontact.lead_id == current_lead.id
    mycontact.original = original if mycontact.original.nil?

    if original
      mycontact.status_contact ||= "approved"
      mycontact.approved_by_referent_at ||= Time.current
    else
      mycontact.status_contact ||= "pending"
    end
  end

  def current_lead
    Current.user&.lead
  end

  def ensure_lead!
    return if current_lead.present?

    redirect_to root_path, alert: "Per gestire i contatti è necessario completare il profilo Lead."
  end

  def set_reference_data
    @datacontacts_scope =
      Datacontact
        .where(lead_id: current_lead.id)
        .or(Datacontact.where(referent_lead_id: current_lead.id))
        .order(:last_name, :first_name)
  end

  def set_datacontact
    @datacontact = Datacontact.find(params.require(:datacontact_id))
  end
end
