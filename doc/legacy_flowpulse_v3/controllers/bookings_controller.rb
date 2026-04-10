class BookingsController < ApplicationController
  before_action :set_booking, only: %i[ show edit update destroy ]
  before_action :set_commitment, only: %i[new create]
  before_action :set_eventdate, only: %i[new create]

  # GET /bookings or /bookings.json
  def index
    @bookings = Booking.all
  end

  # GET /bookings/1 or /bookings/1.json
  def show
  end

  # GET /bookings/new
  def new
    @booking = Booking.new(
      eventdate: @eventdate,
      commitment: @commitment
    )
  end

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings or /bookings.json
  def create
    @booking = Booking.new(booking_params)
    @booking.commitment ||= @commitment
    @booking.eventdate ||= @eventdate || @booking.commitment&.eventdate

    respond_to do |format|
      if @booking.save
        format.html do
          redirect_target = @booking.eventdate || @booking
          notice = "Booking creato con successo."
          redirect_to redirect_target, notice: notice
        end
        format.json { render :show, status: :created, location: @booking }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookings/1 or /bookings/1.json
  def update
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to @booking, notice: "Booking was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @booking }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookings/1 or /bookings/1.json
  def destroy
    @booking.destroy!

    respond_to do |format|
      format.html { redirect_to bookings_path, notice: "Booking was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params.expect(:id))
    end

    def set_commitment
      commitment_id = params[:commitment_id] || params.dig(:booking, :commitment_id)
      @commitment = Commitment.find_by(id: commitment_id)
    end

    def set_eventdate
      eventdate_id = params[:eventdate_id] || params.dig(:booking, :eventdate_id)
      @eventdate = Eventdate.find_by(id: eventdate_id)
      @eventdate ||= @commitment&.eventdate
    end

    # Only allow a list of trusted parameters through.
    def booking_params
      params.expect(booking: [ :service_id, :eventdate_id, :mycontact_id, :enrollment_id, :commitment_id, :status, :mode, :participant_role, :requested_by_lead_id, :invited_by_lead_id, :price_euro, :price_dash, :notes, :meta, :journey_role ])
    end
end
