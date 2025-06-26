class YoutubeUploaderJob < ApplicationJob
  queue_as :uploading
  
  def perform(article_id)
    article = NewsArticle.find(article_id)
    return unless article.status == 'video_ready'
    
    YoutubeUploaderService.new(article).upload
  end
end 