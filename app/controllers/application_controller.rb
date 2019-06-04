class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing,
              with: :render_missing_param_error

  private

  def render_missing_param_error(exception)
    render_error [exception.message], :bad_request
  end

  def render_success(data)
    render json: { data: data }, status: :ok
  end

  def render_error(errors, status = :unprocessable_entity)
    render json: { errors: errors }, status: status
  end
end
