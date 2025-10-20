class AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    # 가입자 통계
    @total_users = User.count
    @users_by_plan = User.group(:plan).count
    @free_users = @users_by_plan['free'] || 0
    @pro_users = @users_by_plan['pro'] || 0
    @lifetime_users = @users_by_plan['lifetime'] || 0

    # 링크 통계
    @total_links = Link.count
    @active_links = Link.where('expires_at IS NULL OR expires_at > ?', Time.current).count
    @total_clicks = Link.sum(:click_count)
    @average_clicks = @total_links > 0 ? (@total_clicks.to_f / @total_links).round(2) : 0

    # 플랜별 링크 통계
    @links_by_plan = Link.left_joins(:user)
                          .group('COALESCE(users.plan, \'guest\')')
                          .select('COALESCE(users.plan, \'guest\') as plan_name, COUNT(links.id) as link_count, SUM(links.click_count) as total_clicks')

    # 인기 링크 TOP 10
    @top_links = Link.left_joins(:user)
                     .where('links.expires_at IS NULL OR links.expires_at > ?', Time.current)
                     .order(click_count: :desc)
                     .limit(10)
                     .select('links.*, users.email as user_email')

    # 수익 통계 (MRR)
    @mrr = @pro_users * 2900
    @lifetime_revenue = @lifetime_users * 29000

    # 전환율
    @conversion_rate = @free_users > 0 ? (((@pro_users + @lifetime_users).to_f / @free_users) * 100).round(2) : 0

    # 최근 30일 신규 가입자
    @recent_signups = User.where('created_at >= ?', 30.days.ago).count

    # 최근 30일 활성 사용자 (링크 생성한 사용자)
    @active_users = User.joins(:links)
                        .where('links.created_at >= ?', 30.days.ago)
                        .distinct
                        .count
  end

  private

  def require_admin!
    unless current_user.lifetime?
      redirect_to root_path, alert: '관리자 권한이 필요합니다.'
    end
  end
end
