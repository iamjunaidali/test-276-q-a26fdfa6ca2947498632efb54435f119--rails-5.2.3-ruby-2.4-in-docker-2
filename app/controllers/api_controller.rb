class ApiController < ApplicationController
  require 'process_exceptions'
  require 'open-uri'
  skip_before_action :verify_authenticity_token
  before_action :require_processing_count

  def process_logs
    result = []
    params[:log_files].each do |link|
      web_contents  = open(link) {|f| f.read }
      data = web_contents.split("\r\n")
      result << ProcessExceptions.new(data).result
    end

    return render json: { response: result[0] }, status: :ok
  end

  private
  def require_processing_count
    return render json: { status: "failure",
                          reason: "Parallel File Processing count must be greater than zero!"
                        }, status: 400 if params[:parallel_file_processing_count].to_i <= 0
  end
end
