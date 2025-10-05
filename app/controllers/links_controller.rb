class LinksController < ApplicationController
  def new
    @link = Link.new
  end

  def create
    @link = Link.new(link_params)
    if @link.save
      redirect_to short_link_path(@link.code), notice: "Link created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @link = Link.find_by!(code: params[:code] || params[:id])
    render layout: false
  end

  private

  def link_params
    params.require(:link).permit(
      :original_url, :cta_text, :cta_link,
      :cta_button_text, :cta_position, :cta_color
    )
  end
end
