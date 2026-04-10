class SlotInstancesController < ApplicationController
  before_action :set_slot_instance, only: %i[ show edit update destroy ]

  # GET /slot_instances or /slot_instances.json
  def index
    @slot_instances = SlotInstance.all
  end

  # GET /slot_instances/1 or /slot_instances/1.json
  def show
  end

  # GET /slot_instances/new
  def new
    @slot_instance = SlotInstance.new
  end

  # GET /slot_instances/1/edit
  def edit
  end

  # POST /slot_instances or /slot_instances.json
  def create
    @slot_instance = SlotInstance.new(slot_instance_params)

    respond_to do |format|
      if @slot_instance.save
        format.html { redirect_to @slot_instance, notice: "Slot instance was successfully created." }
        format.json { render :show, status: :created, location: @slot_instance }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @slot_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /slot_instances/1 or /slot_instances/1.json
  def update
    respond_to do |format|
      if @slot_instance.update(slot_instance_params)
        format.html { redirect_to @slot_instance, notice: "Slot instance was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @slot_instance }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @slot_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /slot_instances/1 or /slot_instances/1.json
  def destroy
    @slot_instance.destroy!

    respond_to do |format|
      format.html { redirect_to slot_instances_path, notice: "Slot instance was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_slot_instance
      @slot_instance = SlotInstance.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def slot_instance_params
      params.expect(slot_instance: [ :slot_template_id, :date_start, :date_end, :status, :notes ])
    end
end
