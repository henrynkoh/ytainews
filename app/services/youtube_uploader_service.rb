class YoutubeUploaderService
  def initialize(news_article)
    @article = news_article
    @youtube = Google::Apis::YoutubeV3::YouTubeService.new
    @youtube.authorization = get_authorization
  end
  
  def upload
    start_time = Time.current
    @article.log_step('upload', 'processing')
    
    video_object = build_video_object
    
    result = @youtube.insert_video(
      'snippet,status',
      video_object,
      upload_source: @article.video_file_path
    )
    
    @article.update!(
      youtube_id: result.id,
      youtube_url: "https://youtube.com/shorts/#{result.id}",
      status: 'uploaded',
      youtube_metadata: {
        published_at: Time.current,
        title: result.snippet.title,
        description: result.snippet.description
      }
    )
    
    processing_time = Time.current - start_time
    
    @article.log_step('upload', 'success', 
                     processing_time: processing_time,
                     metadata: { 
                       youtube_id: result.id,
                       upload_size: File.size(@article.video_file_path)
                     })
    
    result
  rescue => e
    @article.log_step('upload', 'failed', error_message: e.message)
    @article.update!(status: 'failed')
    raise e
  end
  
  private
  
  def get_authorization
    # Use API key for simpler authentication (you'll need OAuth for actual uploads)
    # For now, we'll use a simple API key approach
    @youtube.key = ENV['GOOGLE_API_KEY']
    @youtube
  end
  
  def build_video_object
    Google::Apis::YoutubeV3::Video.new(
      snippet: build_snippet,
      status: Google::Apis::YoutubeV3::VideoStatus.new(
        privacy_status: 'public',
        made_for_kids: false
      )
    )
  end
  
  def build_snippet
    Google::Apis::YoutubeV3::VideoSnippet.new(
      title: generate_youtube_title,
      description: generate_youtube_description,
      tags: generate_youtube_tags,
      category_id: '28',  # Science & Technology
      default_language: 'ko'
    )
  end
  
  def generate_youtube_title
    # Optimize title for YouTube Shorts
    base_title = @article.title.truncate(80)
    "🚨 #{base_title} #AINews #Shorts"
  end
  
  def generate_youtube_description
    """
#{@article.content.truncate(150)}

🔗 원문 링크: #{@article.original_url}
📅 발행일: #{@article.published_at&.strftime('%Y-%m-%d')}
🤖 AI로 자동 생성된 영상입니다

#AI #MachineLearning #TechNews #ArtificialIntelligence #한국어AI뉴스

구독과 좋아요는 최신 AI 뉴스를 빠르게 받아보는 데 도움이 됩니다! 🙏
    """.strip
  end
  
  def generate_youtube_tags
    base_tags = %w[AI 인공지능 머신러닝 테크뉴스 shorts]
    
    # Add source-specific tags
    source_tags = case @article.source.downcase
                  when /openai/ then %w[OpenAI GPT ChatGPT]
                  when /anthropic/ then %w[Anthropic Claude]
                  when /google/ then %w[Google Gemini Bard]
                  when /hugging/ then %w[HuggingFace Transformers]
                  else []
                  end
    
    (base_tags + source_tags).uniq
  end
end 