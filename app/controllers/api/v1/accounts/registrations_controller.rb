class Api::V1::Accounts::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  prepend_before_filter :require_no_authentication, except: :create
  acts_as_token_authentication_handler_for User

  # POST /resource
  def create
    build_resource(sign_up_params.merge(email: params[:user][:email].downcase))
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        set_headers
        render json: {message: "User created Successfully!", success: true, status: 200}
      else
        expire_data_after_sign_in!
        render json: {message: "Session already exists!", success: false, status: 422}
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      render json: {message: resource.errors.full_messages.first, success: false, status: 422}
    end
  end

  private

  def sign_up_params
    params.require(:user).permit( :email, :password)
  end

  def set_headers
    response.headers['X-User-Token'] = resource.authentication_token
    response.header['X-User-Email'] = resource.email
  end

end
