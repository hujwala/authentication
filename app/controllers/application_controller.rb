class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  acts_as_token_authentication_handler_for User

  # def authenticate_user!
  #   unless current_user
  #     return render json: { error: "You are not Authorized!", status: 401 }
  #   end
  #   authenticate_user_from_token!
  # end

  # def authenticate_user_from_token!
  #   request.headers["X-User-Token"].present? && request.headers["X-User-Email"].present?
  # end


end
