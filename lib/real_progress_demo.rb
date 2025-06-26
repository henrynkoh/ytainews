#!/usr/bin/env ruby

require_relative '../config/environment'

class RealProgressDemo
  def self.run
    puts "🎬 AI NEWS SHORTS - REAL PROGRESS TRACKING DEMONSTRATION"
    puts "=" * 65
    puts "This demo will show you the complete progress tracking from beginning to end"
    puts "with REAL data processing through the entire AI pipeline."
    puts
    
    # Step 1: Clean up and prepare
    prepare_demo
    
    # Step 2: Start background services
    start_services
    
    # Step 3: Create and process real articles
    create_and_process_articles
    
    # Step 4: Monitor real-time progress
    monitor_progress
    
    puts "\n✅ REAL PROGRESS DEMONSTRATION COMPLETED!"
    puts "🌐 Visit http://localhost:3000/dashboard to see the beautiful UI"
    puts "📊 Visit http://localhost:3000/dashboard/progress for JSON API"
    puts "🎯 Use 'ruby lib/watch_progress.rb' for live terminal monitoring"
  end
  
  private
  
  def self.prepare_demo
    puts "🧹 STEP 1: PREPARING DEMO ENVIRONMENT"
    puts "-" * 40
    
    # Clean up old demo data
    puts "  🗑️  Cleaning up old demo data..."
    NewsArticle.where("title LIKE ?", "%DEMO%").destroy_all
    GenerationLog.where("created_at < ?", 1.hour.ago).destroy_all
    
    # Check API keys
    puts "  🔑 Checking API configuration..."
    api_status = {
      openai: ENV['OPENAI_API_KEY'].present?,
      elevenlabs: ENV['ELEVENLABS_API_KEY'].present?,
      youtube: ENV['YOUTUBE_API_KEY'].present?
    }
    
    api_status.each do |service, available|
      status = available ? "✅ CONFIGURED" : "❌ MISSING"
      puts "      #{service.upcase}: #{status}"
    end
    
    puts "  ✅ Demo environment prepared!"
    puts
  end
  
  def self.start_services
    puts "🚀 STEP 2: STARTING BACKGROUND SERVICES"
    puts "-" * 40
    
    # Check if Rails server is running
    begin
      response = Net::HTTP.get_response(URI('http://localhost:3000/dashboard/progress'))
      puts "  ✅ Rails server already running on port 3000"
    rescue
      puts "  🔄 Starting Rails server..."
      system("bin/rails server -p 3000 > rails.log 2>&1 &")
      sleep 3
      puts "  ✅ Rails server started"
    end
    
    # Start job worker
    puts "  🔄 Starting background job worker..."
    system("bin/jobs > jobs.log 2>&1 &")
    sleep 2
    puts "  ✅ Background job worker started"
    puts
  end
  
  def self.create_and_process_articles
    puts "📰 STEP 3: CREATING AND PROCESSING REAL ARTICLES"
    puts "-" * 50
    
    # Create realistic demo articles
    demo_articles = [
      {
        title: "DEMO: OpenAI Releases GPT-5 with Revolutionary Capabilities",
        content: "OpenAI has announced the release of GPT-5, featuring unprecedented reasoning abilities and multimodal understanding. The new model demonstrates significant improvements in complex problem-solving, creative tasks, and scientific research applications. Early benchmarks show GPT-5 outperforming previous models by 40% across various evaluation metrics.",
        summary: "OpenAI unveils GPT-5 with groundbreaking AI capabilities and performance improvements",
        original_url: "https://openai.com/gpt-5-announcement",
        source: "OpenAI Blog"
      },
      {
        title: "DEMO: Google's Gemini Ultra Achieves Human-Level Performance",
        content: "Google's latest Gemini Ultra model has achieved human-level performance on complex reasoning tasks, marking a significant milestone in AI development. The model excels in mathematical problem-solving, code generation, and scientific analysis, with researchers noting its ability to explain complex concepts clearly.",
        summary: "Google's Gemini Ultra reaches human-level performance in complex reasoning tasks",
        original_url: "https://deepmind.google/gemini-ultra",
        source: "Google DeepMind"
      },
      {
        title: "DEMO: Anthropic's Claude 4 Introduces Advanced Safety Features",
        content: "Anthropic has released Claude 4 with enhanced safety mechanisms and improved alignment techniques. The new model features advanced constitutional AI training, better refusal capabilities for harmful requests, and improved factual accuracy. Claude 4 also introduces new creative writing capabilities while maintaining strong safety guardrails.",
        summary: "Anthropic launches Claude 4 with advanced safety features and improved alignment",
        original_url: "https://anthropic.com/claude-4",
        source: "Anthropic"
      }
    ]
    
    created_articles = []
    demo_articles.each_with_index do |article_data, index|
      puts "  📝 Creating article #{index + 1}: #{article_data[:title][0..50]}..."
      
      article = NewsArticle.create!(
        title: article_data[:title],
        content: article_data[:content],
        summary: article_data[:summary],
        original_url: article_data[:original_url],
        source: article_data[:source],
        status: 'pending'
      )
      
      created_articles << article
      puts "      ✅ Article created with ID: #{article.id}"
    end
    
    puts "\n  🚀 Queueing articles for processing..."
    created_articles.each do |article|
      puts "      📤 Queueing: #{article.title[0..50]}..."
      NewsProcessingPipelineJob.perform_later(article.id)
    end
    
    puts "  ✅ All articles queued for processing!"
    puts
  end
  
  def self.monitor_progress
    puts "📊 STEP 4: MONITORING REAL-TIME PROGRESS"
    puts "-" * 40
    puts "Watch as articles move through the complete AI pipeline:"
    puts "  PENDING (10%) → SCRIPT_READY (35%) → AUDIO_READY (65%) → VIDEO_READY (85%) → UPLOADED (100%)"
    puts
    
    monitoring_duration = 120 # Monitor for 2 minutes
    start_time = Time.current
    last_status = {}
    
    while (Time.current - start_time) < monitoring_duration
      system('clear') || system('cls')
      
      puts "🎯 REAL-TIME PROGRESS MONITORING"
      puts "=" * 50
      puts "⏰ #{Time.current.strftime('%H:%M:%S')} | Monitoring for #{monitoring_duration - (Time.current - start_time).to_i} more seconds"
      puts
      
      # Get current articles
      demo_articles = NewsArticle.where("title LIKE ?", "%DEMO%").order(:created_at)
      
      if demo_articles.any?
        puts "📊 ACTIVE PROCESSING:"
        puts "=" * 30
        
        demo_articles.each do |article|
          # Calculate progress based on status
          progress_info = case article.status
          when 'pending'
            { percentage: 10, message: 'Generating script...', estimated: '1-2 min', color: '🔄' }
          when 'script_ready'
            { percentage: 35, message: 'Creating audio...', estimated: '2-3 min', color: '🎵' }
          when 'audio_ready'
            { percentage: 65, message: 'Generating video...', estimated: '3-4 min', color: '🎬' }
          when 'video_ready'
            { percentage: 85, message: 'Uploading to YouTube...', estimated: '1-2 min', color: '📤' }
          when 'uploaded', 'published'
            { percentage: 100, message: 'Complete!', estimated: 'Done', color: '✅' }
          else
            { percentage: 0, message: 'Initializing...', estimated: 'N/A', color: '⏳' }
          end
          
          # Show progress bar
          bar_length = 30
          filled_length = (bar_length * progress_info[:percentage] / 100).to_i
          bar = '█' * filled_length + '░' * (bar_length - filled_length)
          
          puts "#{progress_info[:color]} #{article.title[0..45]}..."
          puts "   [#{bar}] #{progress_info[:percentage]}%"
          puts "   Status: #{progress_info[:message]} (#{progress_info[:estimated]})"
          
          # Check for status changes
          if last_status[article.id] != article.status
            puts "   🔄 STATUS CHANGED: #{last_status[article.id] || 'NEW'} → #{article.status.upcase}"
            last_status[article.id] = article.status
          end
          
          puts
        end
        
        # Show completion summary
        completed = demo_articles.where(status: ['uploaded', 'published']).count
        total = demo_articles.count
        puts "📈 OVERALL PROGRESS: #{completed}/#{total} articles completed (#{(completed.to_f / total * 100).round}%)"
        
        # Check if all completed
        if completed == total
          puts "\n🎉 ALL ARTICLES COMPLETED! Demo finished successfully."
          break
        end
        
      else
        puts "⏳ No demo articles found. Creating articles..."
      end
      
      puts "\n💡 TIP: Visit http://localhost:3000/dashboard for the beautiful web interface!"
      puts "📊 API: http://localhost:3000/dashboard/progress"
      
      sleep 3
    end
    
    puts "\n⏰ Monitoring period completed."
  end
end

# Run the demo if this file is executed directly
if __FILE__ == $0
  RealProgressDemo.run
end 