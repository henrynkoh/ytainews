class NewsProcessingPipelineJob < ApplicationJob
  queue_as :default
  
  def perform
    # Process articles through the entire pipeline
    NewsArticle.pending_processing.find_each do |article|
      case article.status
      when 'pending'
        ScriptGeneratorJob.perform_later(article.id)
      when 'script_ready'
        AudioGeneratorJob.perform_later(article.id)
      when 'audio_ready'
        VideoGeneratorJob.perform_later(article.id)
      when 'video_ready'
        YoutubeUploaderJob.perform_later(article.id)
      end
    end
  end
end 