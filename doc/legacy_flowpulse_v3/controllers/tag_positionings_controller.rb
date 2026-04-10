class TagPositioningsController < ApplicationController
  before_action :set_tag_positioning, only: %i[ show edit update destroy ]
  before_action :set_taxbranch

  # GET /tag_positionings or /tag_positionings.json
  def index
    if params[:taxbranch_id]
      set_taxbranch
      @tags = @taxbranch.tag_positionings.order(:category, :name)

      @categories = TagPositioning.categories_for(@taxbranch.id)
    else
      @tags = TagPositioning.all
    end
    @default_categories = %w[problema target keyword messaggio servizio concorrente contenuto]
  end



  # GET /tag_positionings/1 or /tag_positionings/1.json
  def show
  end

  # GET /tag_positionings/new
  def new
    @tag_positioning = @taxbranch.TagPositionings.build
    @tag.lead = Current.lead
  end

  # GET /tag_positionings/1/edit
  def edit
  end

 # POST /tag_positionings or /tag_positionings.json
 def create
    @tag = @taxbranch.TagPositionings.build(tag_params)
    @tag.lead = Current.lead
    if @tag.save
      redirect_to taxbranch_tag_positionings_path(@taxbranch), notice: "Aggiunto."
    else
      @tags = @taxbranch.tag_positionings.order(:category, :name)
      @categories = TagPositioning.categories_for(@taxbranch.id)
      @default_categories = %w[problema target keyword messaggio servizio concorrente contenuto]
      flash.now[:alert] = "Errore."
      render :index, status: :unprocessable_entity
    end
  end



  # PATCH/PUT /tag_positionings/1 or /tag_positionings/1.json
  def update
    respond_to do |format|
      if @tag_positioning.update(tag_positioning_params)
        format.html { redirect_to @tag_positioning, notice: "Tag positioning was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @tag_positioning }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tag_positioning.errors, status: :unprocessable_entity }
      end
    end
  end

   # DELETE /tag_positionings/1 or /tag_positionings/1.json
   def destroy
    @taxbranch.tag_positionings.find(params[:id]).destroy
    redirect_to taxbranch_tag_positionings_path(@taxbranch), notice: "Rimosso."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag_positioning
      @tag_positioning = TagPositioning.find(params.expect(:id))
    end

     def set_taxbranch
      if params[:taxbranch_id]
      # Se usi friendly_id:
      @taxbranch = Taxbranch.find_by(id: params[:taxbranch_id]) ||
                  Taxbranch.find_by(slug: params[:taxbranch_id])
      redirect_to taxbranches_path, alert: "Taxbranch non trovato." if @taxbranch.nil?
      end
    end



    # Only allow a list of trusted parameters through.
    def tag_positioning_params
      params.expect(tag_positioning: [ :taxbranch_id, :name, :category, :metadata, :lead ])
    end
end
