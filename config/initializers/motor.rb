# Motor Admin authentication
Rails.application.config.to_prepare do
  Motor::ApplicationController.class_eval do
    before_action :authenticate_admin!

    def authenticate_admin!
      authenticate_user!

      unless current_user.lifetime?
        redirect_to root_path, alert: '관리자 권한이 필요합니다.'
      end
    end
  end
end
