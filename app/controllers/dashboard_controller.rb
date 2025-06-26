class DashboardController < ApplicationController
  def index
    @today_count = NewsArticle.where(created_at: Date.current.all_day).count
    @total_views = NewsArticle.sum(:views) || 0
    @success_rate = calculate_success_rate
    @pending_count = NewsArticle.where(status: ['pending', 'script_ready', 'audio_ready', 'video_ready', 'uploaded']).count
    
    @recent_videos = NewsArticle.order(created_at: :desc).limit(20)
    @failed_jobs = GenerationLog.where(status: 'failed').includes(:news_article).limit(10)
    @daily_stats = daily_statistics
  end
  
  # Start crawling action with progress tracking
  def start_crawling
    # Store crawling session info
    session[:crawling_started_at] = Time.current
    session[:crawling_progress] = 0
    session[:crawling_status] = 'starting'
    session[:crawling_message] = 'Initializing news crawler...'
    
    # Trigger the crawling job in background
    NewsCrawlerJob.perform_later
    
    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: 'News crawling started! Check progress below.' }
      format.json { render json: { status: 'started', message: 'Crawling initiated' } }
    end
  end
  
  # Process pipeline action  
  def process_pipeline
    pending_articles = NewsArticle.where(status: 'pending').limit(5)
    
    if pending_articles.any?
      session[:pipeline_started_at] = Time.current
      session[:pipeline_progress] = 0
      session[:pipeline_total] = pending_articles.count
      session[:pipeline_status] = 'processing'
      
      pending_articles.each do |article|
        NewsProcessingPipelineJob.perform_later(article.id)
      end
      
      respond_to do |format|
        format.html { redirect_to dashboard_path, notice: "Processing #{pending_articles.count} articles through AI pipeline!" }
        format.json { render json: { status: 'started', count: pending_articles.count } }
      end
    else
      respond_to do |format|
        format.html { redirect_to dashboard_path, alert: 'No pending articles to process. Run crawling first!' }
        format.json { render json: { status: 'error', message: 'No pending articles' } }
      end
    end
  end
  
  # Real-time progress endpoint
  def progress
    crawling_progress = calculate_crawling_progress
    pipeline_progress = calculate_pipeline_progress
    
    render json: {
      crawling: crawling_progress,
      pipeline: pipeline_progress,
      timestamp: Time.current.to_i
    }
  end
  
  # Logs view
  def logs
    @recent_logs = GenerationLog.includes(:news_article)
                                .order(created_at: :desc)
                                .limit(50)
  end
  
  def retry_article
    article = NewsArticle.find(params[:id])
    NewsProcessingPipelineJob.perform_later(article.id)
    redirect_to dashboard_path, notice: "Retrying processing for: #{article.title}"
  end
  
  private
  
  def calculate_success_rate
    total = NewsArticle.count
    return 0 if total.zero?
    
    successful = NewsArticle.where(status: ['uploaded', 'published']).count
    ((successful.to_f / total) * 100).round
  end
  
  def calculate_crawling_progress
    return { active: false } unless session[:crawling_started_at]
    
    started_at = Time.parse(session[:crawling_started_at].to_s)
    elapsed = Time.current - started_at
    
    # Estimate 30-60 seconds for crawling
    estimated_duration = 45.0
    progress = [(elapsed / estimated_duration * 100).round, 100].min
    
    # Check if any new articles were created recently
    new_articles = NewsArticle.where(created_at: started_at..).count
    
    if progress >= 100 || new_articles > 0
      session[:crawling_started_at] = nil
      return {
        active: false,
        completed: true,
        articles_found: new_articles
      }
    end
    
    {
      active: true,
      progress: progress,
      elapsed: elapsed.round,
      estimated_remaining: (estimated_duration - elapsed).round.clamp(0, Float::INFINITY),
      message: get_crawling_message(progress)
    }
  end
  
  def calculate_pipeline_progress
    return { active: false } unless session[:pipeline_started_at]
    
    started_at = Time.parse(session[:pipeline_started_at].to_s)
    total_articles = session[:pipeline_total] || 1
    
    # Count completed articles since pipeline started
    completed = NewsArticle.where(
      updated_at: started_at..,
      status: ['uploaded', 'published']
    ).count
    
    processing = NewsArticle.where(
      status: ['script_ready', 'audio_ready', 'video_ready']
    ).count
    
    progress = [(completed.to_f / total_articles * 100).round, 100].min
    
    if progress >= 100
      session[:pipeline_started_at] = nil
      return {
        active: false,
        completed: true,
        articles_processed: completed
      }
    end
    
    {
      active: true,
      progress: progress,
      completed: completed,
      processing: processing,
      total: total_articles,
      message: get_pipeline_message(completed, processing, total_articles)
    }
  end
  
  def get_crawling_message(progress)
    case progress
    when 0..20
      "🔍 Connecting to AI news sources..."
    when 21..40  
      "📰 Fetching latest articles from RSS feeds..."
    when 41..60
      "🤖 Processing OpenAI blog updates..."
    when 61..80
      "🧠 Scanning Anthropic and Google AI news..."
    else
      "✅ Finalizing article collection..."
    end
  end
  
  def get_pipeline_message(completed, processing, total)
    if processing > 0
      "🎬 Processing videos: #{completed}/#{total} completed, #{processing} in progress"
    else
      "⚡ Starting AI pipeline: #{completed}/#{total} completed"
    end
  end
  
  def daily_statistics
    (7.days.ago.to_date..Date.current).map do |date|
      total = NewsArticle.where(created_at: date.all_day).count
      successful = NewsArticle.where(created_at: date.all_day, status: ['uploaded', 'published']).count
      
      {
        date: date,
        total: total,
        successful: successful,
        rate: total > 0 ? (successful.to_f / total * 100).round : 0
      }
    end
  end
end 