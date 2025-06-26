#!/usr/bin/env ruby

# Complete Progress Tracking Demonstration
# This script demonstrates the full AI News Shorts pipeline with real-time progress tracking

require_relative '../config/environment'

class ProgressDemo
  def self.run
    puts "🎬 AI NEWS SHORTS - COMPLETE PROGRESS DEMONSTRATION"
    puts "=" * 60
    
    # Step 1: Clean up any existing demo data
    cleanup_demo_data
    
    # Step 2: Create test articles
    articles = create_demo_articles
    
    # Step 3: Start background job worker (if not running)
    ensure_job_worker_running
    
    # Step 4: Start Rails server (if not running)
    ensure_rails_server_running
    
    # Step 5: Demonstrate progress tracking
    demonstrate_progress_tracking(articles)
    
    puts "\n✅ DEMONSTRATION COMPLETE!"
    puts "🌐 Visit http://localhost:3000/dashboard to see the live progress"
    puts "📊 Real-time progress endpoint: http://localhost:3000/dashboard/progress"
  end
  
  private
  
  def self.cleanup_demo_data
    puts "\n🧹 Cleaning up previous demo data..."
    NewsArticle.where("title LIKE ?", "%Demo:%").destroy_all
    GenerationLog.where("step LIKE ?", "%Demo%").destroy_all
    puts "   ✅ Cleanup complete"
  end
  
  def self.create_demo_articles
    puts "\n📰 Creating demo articles for progress tracking..."
    
    articles = [
      {
        title: "Demo: OpenAI Announces GPT-5 with Revolutionary Capabilities",
        content: "OpenAI today announced GPT-5, a groundbreaking AI model that represents a significant leap forward in artificial intelligence capabilities. The new model features enhanced reasoning, improved factual accuracy, and revolutionary multimodal understanding that surpasses all previous versions.",
        summary: "OpenAI unveils GPT-5 with game-changing AI capabilities",
        source: "OpenAI Blog",
        original_url: "https://openai.com/gpt-5-demo"
      },
      {
        title: "Demo: Google's Gemini Ultra Achieves Human-Level Performance",
        content: "Google's latest AI model, Gemini Ultra, has achieved human-level performance across multiple benchmarks. This breakthrough represents a major milestone in AI development, with implications for scientific research, creative industries, and everyday applications.",
        summary: "Google's Gemini Ultra reaches human-level AI performance",
        source: "Google AI Blog", 
        original_url: "https://ai.google.com/gemini-ultra-demo"
      },
      {
        title: "Demo: Anthropic's Claude 4 Introduces Advanced Safety Features",
        content: "Anthropic has released Claude 4, featuring unprecedented safety mechanisms and constitutional AI principles. The model demonstrates remarkable alignment with human values while maintaining exceptional performance across diverse tasks.",
        summary: "Anthropic launches Claude 4 with enhanced AI safety",
        source: "Anthropic Blog",
        original_url: "https://anthropic.com/claude-4-demo"
      }
    ]
    
    created_articles = []
    articles.each_with_index do |article_data, index|
      article = NewsArticle.create!(
        title: article_data[:title],
        content: article_data[:content],
        summary: article_data[:summary],
        source: article_data[:source],
        original_url: article_data[:original_url],
        status: 'pending'
      )
      created_articles << article
      puts "   ✅ Created: #{article.title}"
    end
    
    created_articles
  end
  
  def self.ensure_job_worker_running
    puts "\n⚙️  Checking background job worker..."
    
    # Check if Solid Queue processes are running
    active_processes = SolidQueue::Process.all.count rescue 0
    
    if active_processes == 0
      puts "   🚀 Starting background job worker..."
      system("bin/jobs > jobs.log 2>&1 &")
      sleep(3) # Give it time to start
      
      new_processes = SolidQueue::Process.all.count rescue 0
      if new_processes > 0
        puts "   ✅ Job worker started (#{new_processes} processes)"
      else
        puts "   ⚠️  Job worker may not have started properly"
      end
    else
      puts "   ✅ Job worker already running (#{active_processes} processes)"
    end
  end
  
  def self.ensure_rails_server_running
    puts "\n🌐 Checking Rails server..."
    
    begin
      response = Net::HTTP.get_response(URI('http://localhost:3000/dashboard'))
      if response.code == '200'
        puts "   ✅ Rails server already running on port 3000"
      end
    rescue
      puts "   🚀 Starting Rails server..."
      system("bin/rails server -p 3000 > rails.log 2>&1 &")
      sleep(5) # Give it time to start
      
      begin
        response = Net::HTTP.get_response(URI('http://localhost:3000/dashboard'))
        if response.code == '200'
          puts "   ✅ Rails server started successfully"
        else
          puts "   ⚠️  Rails server may not have started properly"
        end
      rescue
        puts "   ⚠️  Rails server startup verification failed"
      end
    end
  end
  
  def self.demonstrate_progress_tracking(articles)
    puts "\n🎯 STARTING PROGRESS TRACKING DEMONSTRATION"
    puts "=" * 50
    
    # Queue all articles for processing
    articles.each do |article|
      puts "🚀 Queueing pipeline for: #{article.title[0..50]}..."
      NewsProcessingPipelineJob.perform_later(article.id)
    end
    
    puts "\n📊 REAL-TIME PROGRESS TRACKING:"
    puts "=" * 40
    
    # Monitor progress for up to 5 minutes
    start_time = Time.current
    max_duration = 5.minutes
    last_status = {}
    
    while Time.current - start_time < max_duration
      all_complete = true
      
      articles.each do |article|
        article.reload
        current_status = article.status
        
        # Only show status changes
        if last_status[article.id] != current_status
          progress_info = get_progress_info(current_status)
          puts "📈 #{article.title[0..40]}... → #{current_status.upcase} (#{progress_info[:percentage]}%) - #{progress_info[:message]}"
          last_status[article.id] = current_status
        end
        
        if !['uploaded', 'published', 'failed'].include?(current_status)
          all_complete = false
        end
      end
      
      if all_complete
        puts "\n🎉 ALL ARTICLES PROCESSED SUCCESSFULLY!"
        break
      end
      
      sleep(3) # Check every 3 seconds
    end
    
    # Final status report
    puts "\n📋 FINAL STATUS REPORT:"
    puts "=" * 30
    articles.each do |article|
      article.reload
      progress_info = get_progress_info(article.status)
      puts "#{article.status.upcase.ljust(12)} (#{progress_info[:percentage].to_s.rjust(3)}%) - #{article.title[0..50]}..."
    end
    
    # Show generation logs if any
    failed_logs = GenerationLog.where(status: 'failed').includes(:news_article)
    if failed_logs.any?
      puts "\n❌ FAILED PROCESSES:"
      failed_logs.each do |log|
        puts "   #{log.news_article.title[0..40]}... - #{log.step}: #{log.error_message}"
      end
    end
  end
  
  def self.get_progress_info(status)
    case status
    when 'pending'
      { percentage: 10, message: 'Generating script...', estimated: '1-2 min' }
    when 'script_ready'
      { percentage: 35, message: 'Creating audio...', estimated: '2-3 min' }
    when 'audio_ready'
      { percentage: 65, message: 'Generating video...', estimated: '3-4 min' }
    when 'video_ready'
      { percentage: 85, message: 'Uploading to YouTube...', estimated: '1-2 min' }
    when 'uploaded', 'published'
      { percentage: 100, message: 'Complete!', estimated: 'Done' }
    when 'failed'
      { percentage: 0, message: 'Failed - Check logs', estimated: 'Error' }
    else
      { percentage: 0, message: 'Unknown status', estimated: 'Unknown' }
    end
  end
end

# Run the demonstration if called directly
if __FILE__ == $0
  ProgressDemo.run
end 