class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  
  def admin_required
    authenticate_or_request_with_http_basic do |username, password|
      Admin.find_by_username_and_password(username, password)
    end
  end
  
end
