class Api::V1::Accounts::SessionsController < Devise::SessionsController
  respond_to :json
  acts_as_token_authentication_handler_for User
  before_action :user_params, except: [:destroy]
  prepend_before_filter :require_no_authentication, except: [:create, :destroy]

  # POST /resource/sign_in
  def create
    binding.pry
    @user = User.find_by(email: params[:user][:email].downcase)
    if @user.present?
        if @user.valid_password? params[:user][:password]
          self.resource = warden.authenticate!(auth_options)
          sign_in(resource_name, resource)
          set_headers(@user)
          render json: {user: @user.as_json, message: 'Logged in successfully!', status: 200, success: true }
        else
          render json: { error: 'It looks like your email or password are invalid!', status: 422, success: false }
        end
    else
      render json: { error: 'It looks like your email or password are invalid!', status: 404, success: false }
    end
  end

   # DELETE /resource/sign_out
   def destroy
    if request.headers["X-User-Token"].present?
      @user = User.find_by_authentication_token(request.headers["X-User-Token"])
      if request.headers["X-User-Token"]==@user.authentication_token
        @user.update_attributes(authentication_token: nil)
        sign_out @user
        render json: { message: 'Logged out Successfully!', status: 200, success: true }
      else
        render json: { error: 'Failed to log out. User must be logged in!', status: 422, success: false }
      end
    else
        render json: { error: 'You are not authorized!', status: 422, success: false }
    end
  end

  private

  def user_params
    @user = User.find_by(email: params[:user][:email])
  end

  def set_headers(resource)
    response.headers['X-User-Token'] = resource.authentication_token
    response.header['X-User-Email'] = resource.email
  end

end
