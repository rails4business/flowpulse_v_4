class CertificatesController < ApplicationController
  before_action :set_certificate, only: %i[ show edit update destroy ]

  # GET /certificates or /certificates.json
  def index
    @certificates = Certificate.all
  end

  # GET /certificates/1 or /certificates/1.json
  def show
  end

  # GET /certificates/new
  def new
    @certificate = Certificate.new
  end

  # GET /certificates/1/edit
  def edit
  end

  # POST /certificates or /certificates.json
  def create
    @certificate = Certificate.new(certificate_params)

    respond_to do |format|
      if @certificate.save
        format.html { redirect_to @certificate, notice: "Certificate was successfully created." }
        format.json { render :show, status: :created, location: @certificate }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @certificate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /certificates/1 or /certificates/1.json
  def update
    respond_to do |format|
      if @certificate.update(certificate_params)
        format.html { redirect_to @certificate, notice: "Certificate was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @certificate }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @certificate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /certificates/1 or /certificates/1.json
  def destroy
    @certificate.destroy!

    respond_to do |format|
      format.html { redirect_to certificates_path, notice: "Certificate was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_certificate
      @certificate = Certificate.includes(:domain_membership, :domain, :lead).find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def certificate_params
      params.expect(certificate: certificate_permitted_attributes)
    end

    def certificate_permitted_attributes
      attrs = [
        :lead_id, :datacontact_id, :enrollment_id, :service_id, :journey_id,
        :taxbranch_id, :role_name, :status, :issued_at, :expires_at,
        :issued_by_enrollment_id, :meta
      ]
      attrs << :domain_membership_id if Certificate.column_names.include?("domain_membership_id")
      attrs << :domain_id if Certificate.column_names.include?("domain_id")
      attrs
    end
end
