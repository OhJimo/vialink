class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @links = current_user.links.order(created_at: :desc)
    @current_month_links_count = current_user.current_month_links_count
    @monthly_limit = current_user.monthly_link_limit
    @remaining_links = @monthly_limit - @current_month_links_count
  end
end
