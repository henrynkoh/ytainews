class Api::V1::PipelineController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def start
    NewsProcessingPipelineJob.perform_later
    
    render json: { 
      status: 'success', 
      message: 'Processing pipeline started',
      pending_count: NewsArticle.pending_processing.count,
      timestamp: Time.current
    }
  end
end 