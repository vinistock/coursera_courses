class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::ImplicitRender

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from Mongoid::Errors::DocumentNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :missing_parameter

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def full_message_error(full_message, status)
    payload = { errors: { full_messages: [full_message] } }
    render json: payload, status: status
  end

  def record_not_found(exception)
    full_message_error("cannot find id[#{params[:id]}]", :not_found)
    Rails.logger.debug exception.message
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i(name))
  end

  def missing_parameter(exception)
    payload = { errors: { full_messages:["#{exception.message}"] } }
    render json: payload, status: :bad_request
    Rails.logger.debug exception.message
  end
end
