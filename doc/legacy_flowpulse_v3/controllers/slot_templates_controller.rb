class SlotTemplatesController < ApplicationController
  before_action :set_slot_template, only: %i[ show edit update destroy ]

  # GET /slot_templates or /slot_templates.json
  def index
    @slot_templates = SlotTemplate.all
  end

  # GET /slot_templates/1 or /slot_templates/1.json
  def show
  end

  # GET /slot_templates/new
  def new
    @slot_template = SlotTemplate.new
  end

  # GET /slot_templates/1/edit
  def edit
  end

  # POST /slot_templates or /slot_templates.json
  def create
    @slot_template = SlotTemplate.new(slot_template_params)

    respond_to do |format|
      if @slot_template.save
        format.html { redirect_to @slot_template, notice: "Slot template was successfully created." }
        format.json { render :show, status: :created, location: @slot_template }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @slot_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /slot_templates/1 or /slot_templates/1.json
  def update
    respond_to do |format|
      if @slot_template.update(slot_template_params)
        format.html { redirect_to @slot_template, notice: "Slot template was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @slot_template }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @slot_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /slot_templates/1 or /slot_templates/1.json
  def destroy
    @slot_template.destroy!

    respond_to do |format|
      format.html { redirect_to slot_templates_path, notice: "Slot template was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_slot_template
      @slot_template = SlotTemplate.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def slot_template_params
      params.expect(slot_template: [ :lead_id, :title, :description, :day_of_week, :time_start, :time_end, :repeat_rule, :repeat_every, :repeat_start, :repeat_end, :seasons, :jsonb, :color_hex, :taxbranch_id ])
    end
end
