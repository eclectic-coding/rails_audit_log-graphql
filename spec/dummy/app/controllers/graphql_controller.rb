class GraphqlController < ApplicationController
  skip_before_action :verify_authenticity_token

  def execute
    result = DummySchema.execute(
      params[:query],
      variables: params[:variables],
      context: {},
      operation_name: params[:operationName]
    )
    render json: result
  rescue => e
    raise e unless Rails.env.development?

    render json: {errors: [{message: e.message, backtrace: e.backtrace}]}, status: 500
  end
end
