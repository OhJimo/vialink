class LinksController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :check_link_limit, only: [:create]
  before_action :check_customization, only: [:create]

  def new
    @link = current_user.links.build
  end

  def create
    @link = current_user.links.build(link_params)
    if @link.save
      redirect_to dashboard_path, notice: "링크가 생성되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @link = Link.find_by!(code: params[:code] || params[:id])

    if @link.expired?
      render :expired, layout: false
    else
      @link.increment_clicks!
      render layout: false
    end
  end

  def destroy
    @link = current_user.links.find(params[:id])
    @link.destroy
    redirect_to dashboard_path, notice: "링크가 삭제되었습니다."
  end

  private

  def link_params
    params.require(:link).permit(
      :original_url, :cta_text, :cta_link,
      :cta_button_text, :cta_position, :cta_color
    )
  end

  def check_link_limit
    unless current_user.can_create_link?
      redirect_to dashboard_path,
                  alert: "이번 달 링크 생성 한도(#{current_user.monthly_link_limit}개)를 초과했습니다."
    end
  end

  def check_customization
    # Free 플랜 사용자는 커스터마이징 불가
    if current_user.free? && customization_requested?
      # 기본값으로 재설정
      params[:link][:cta_color] = nil
      params[:link][:cta_position] = "center"
    end
  end

  def customization_requested?
    params[:link][:cta_color].present? ||
    (params[:link][:cta_position].present? && params[:link][:cta_position] != "center")
  end
end
