class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update, :destroy]
  before_action :check_auth, except: [:show_image, :show_thumb]

  def show_image
    set_picture
    send_data @picture.origin, :type => 'image/jpeg', :disposition => "inline"
  end
  
  def show_thumb
    set_picture
    send_data @picture.thumb, :type => 'image/jpeg', :disposition => "inline"
  end

  def show_images
    if params[:p].blank? || params[:checked_id].blank?
      raise ActionController::RoutingError.new(params[:path])
    end
    @checked_id = params[:checked_id]
    ps = 6
    o = params[:p].to_i * ps
    @pictures = Picture.active.offset(o).limit(ps)
    render :action => 'show_images', :layout => false
  end

  # GET /pictures
  # GET /pictures.json
  def index
    @pictures = Picture.all
  end

  # GET /pictures/1
  # GET /pictures/1.json
  def show
  end

  # GET /pictures/new
  def new
    @picture = Picture.new
  end

  # GET /pictures/1/edit
  def edit
  end

  # POST /pictures
  # POST /pictures.json
  def create
    @picture = Picture.new(picture_params)
    @picture.thumb = 

    respond_to do |format|
      if @picture.save
        format.html { redirect_to @picture, notice: 'Picture was successfully created.' }
        format.json { render :show, status: :created, location: @picture }
      else
        format.html { render :new }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pictures/1
  # PATCH/PUT /pictures/1.json
  def update
    respond_to do |format|
      if @picture.update(picture_params)
        format.html { redirect_to @picture, notice: 'Picture was successfully updated.' }
        format.json { render :show, status: :ok, location: @picture }
      else
        format.html { render :edit }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.json
  def destroy
    @picture.destroy
    respond_to do |format|
      format.html { redirect_to pictures_url, notice: 'Picture was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_picture
      @picture = Picture.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def picture_params
      require 'RMagick'
      p = params.require(:picture).permit(:origin,:desc)
      if p[:origin] != nil then
        p[:origin] = p[:origin].read
        i = Magick::Image.from_blob(p[:origin])[0]
        if i.columns > 1024
          p[:origin] = i.resize(0.5).to_blob
        end
        t = i.resize_to_fill(128)
        p[:thumb] = t.to_blob
      end
      p[:master_id] = session[:master_id];
      return p
    end
end
