class LinksController < ApplicationController
  before_action :authenticate_user!, except: [:show, :new, :create]
  before_action :check_link_limit, only: [:create]
  before_action :check_customization, only: [:create]

  def new
    @link = Link.new
  end

  def create
    @link = Link.new(link_params)

    # 로그인 사용자인 경우 user 연결
    @link.user = current_user if user_signed_in?

    if @link.save
      # 게스트 사용자는 세션에 카운트 증가
      increment_guest_link_count unless user_signed_in?

      flash[:notice] = "링크가 생성되었습니다!"
      flash[:link_code] = @link.code
      redirect_to root_path
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
    # 로그인 사용자 체크
    if user_signed_in?
      unless current_user.can_create_link?
        redirect_to dashboard_path,
                    alert: "이번 달 링크 생성 한도(#{current_user.monthly_link_limit}개)를 초과했습니다."
        return
      end
    else
      # 게스트 사용자 체크 (세션 기반)
      guest_count = session[:guest_link_count] || 0
      if guest_count >= 3  # 게스트는 3개까지만
        flash[:alert] = "무료 사용 한도(3개)를 초과했습니다. 회원가입하고 더 많은 기능을 이용하세요!"
        redirect_to new_user_registration_path
      end
    end
  end

  def check_customization
    # 게스트 사용자는 커스터마이징 불가
    unless user_signed_in?
      params[:link][:cta_color] = nil
      params[:link][:cta_position] = "center"
      return
    end

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

  def increment_guest_link_count
    session[:guest_link_count] ||= 0
    session[:guest_link_count] += 1
  end
end
