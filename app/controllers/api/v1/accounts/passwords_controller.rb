class Api::V1::Accounts::PasswordsController < Devise::PasswordsController
  prepend_before_action :require_no_authentication, except: [:create, :edit, :update]
  append_before_action :assert_reset_token_passed, only: :edit

  def create
    binding.pry
    self.resource = resource_class.send_reset_password_instructions(params[:password])
    if successfully_sent?(resource)
      render json: { user: self.resource , success: true, status: 200, message: "An email has been sent to '#{resource.email}' containing instructions for resetting your password."}
    else
      render json: { error: resource.errors.full_messages.first, success: false, status: 422}
    end
  end

  def edit
    resource = User.find(params[:resource])
    resource.reset_password_token = params[:reset_password_token]
    if resource
      yield resource if block_given?
      redirect_to "konnexe://X-User-Token/#{resource.authentication_token}/id/#{resource.id}/reset_password_token/#{resource.reset_password_token}"
    else
      @error = "This link has expired"
      redirect_to "konnexe://error/#{@error}"
    end
  end

  def update
    if params[:user].nil?
      render json: { error: "You must fill out the fields labeled 'Password' and 'Password confirmation'.", status: 422, success: false }
    else
      self.resource = resource_class.reset_password_by_token(params[:user])
      if resource.errors.empty?
        resource.active_for_authentication? ? :updated : :updated_not_active
        render json: { user: UserSerializer.new(resource).serializable_hash, status: 200, success: true, message: "Your password has been successfully updated!" }
      else
        render json: { error: resource.errors.full_messages.first, status: 422, success: false }
      end
    end
  end

end

