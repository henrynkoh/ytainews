class VideoGeneratorJob < ApplicationJob
  queue_as :video_processing
  
  def perform(article_id)
    article = NewsArticle.find(article_id)
    return unless article.status == 'audio_ready'
    
    VideoGeneratorService.new(article).generate
  end
end 