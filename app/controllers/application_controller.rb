class ApplicationController < ActionController::API
  include ApiExceptions


  rescue_from StandardError do |exception|
    raise exception if Rails.env.development? && params[:force].blank?

    message = 'something happened which was not quite expected'
    code = 1000

    render json: {
      status: 'error',
      error: {
        message: message,
        code: code
      }
    }, status: :unprocessable_entity
  end

  #
  # To standarize the api response
  #
  def jsonator data
    render json: {
      status: 'success',
      data: data
    }, status: :ok
  end
end
