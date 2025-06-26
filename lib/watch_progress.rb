#!/usr/bin/env ruby

require_relative '../config/environment'

class ProgressWatcher
  def self.watch
    puts "🎯 WATCHING COMPLETE PROGRESS TRACKING"
    puts "=" * 50
    puts "Press Ctrl+C to stop watching\n\n"
    
    last_status = {}
    
    loop do
      system('clear') || system('cls') # Clear screen
      
      puts "🎯 AI NEWS SHORTS - LIVE PROGRESS TRACKING"
      puts "=" * 50
      puts "⏰ #{Time.current.strftime('%H:%M:%S')} | 🔄 Auto-refresh every 3 seconds"
      puts
      
      # Show active articles
      active_articles = NewsArticle.where.not(status: ['uploaded', 'published']).order(:created_at)
      completed_articles = NewsArticle.where(status: ['uploaded', 'published']).order(:created_at)
      
      if active_articles.any?
        puts "📊 ACTIVE PROCESSING:"
        puts "=" * 30
        
        active_articles.each do |article|
          progress_info = get_progress_info(article.status)
          progress_bar = create_progress_bar(progress_info[:percentage])
          
          # Check if status changed
          status_changed = last_status[article.id] != article.status
          indicator = status_changed ? "🆕" : "  "
          
          puts "#{indicator} #{article.title[0..40]}..."
          puts "    Status: #{article.status.upcase} (#{progress_info[:percentage]}%)"
          puts "    #{progress_bar} #{progress_info[:message]}"
          puts "    ⏱️  #{progress_info[:estimated]}"
          puts
          
          last_status[article.id] = article.status
        end
      else
        puts "✅ No articles currently processing"
        puts
      end
      
      if completed_articles.any?
        puts "🎉 COMPLETED ARTICLES:"
        puts "=" * 25
        completed_articles.each do |article|
          puts "✅ #{article.title[0..50]}... (#{article.status.upcase})"
        end
        puts
      end
      
      # Show recent logs
      recent_logs = GenerationLog.includes(:news_article).order(:created_at).last(5)
      if recent_logs.any?
        puts "📋 RECENT ACTIVITY:"
        puts "=" * 20
        recent_logs.each do |log|
          time_ago = time_ago_in_words(log.created_at)
          status_icon = log.status == 'success' ? '✅' : (log.status == 'failed' ? '❌' : '🔄')
          puts "#{status_icon} #{log.news_article.title[0..30]}... - #{log.step} (#{time_ago} ago)"
        end
        puts
      end
      
      # Show queue status
      begin
        job_count = SolidQueue::Job.where(finished_at: nil).count
        process_count = SolidQueue::Process.all.count
        puts "⚙️  Queue: #{job_count} jobs pending | #{process_count} workers active"
      rescue => e
        puts "⚙️  Queue status unavailable"
      end
      
      puts "\n🌐 Dashboard: http://localhost:3000/dashboard"
      puts "📊 Progress API: http://localhost:3000/dashboard/progress"
      
      sleep(3)
    end
  rescue Interrupt
    puts "\n\n👋 Progress watching stopped. Thanks for watching!"
  end
  
  private
  
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
  
  def self.create_progress_bar(percentage)
    bar_length = 20
    filled_length = (bar_length * percentage / 100).round
    bar = '█' * filled_length + '░' * (bar_length - filled_length)
    "[#{bar}] #{percentage}%"
  end
  
  def self.time_ago_in_words(time)
    seconds = (Time.current - time).to_i
    
    case seconds
    when 0..59
      "#{seconds}s"
    when 60..3599
      "#{seconds / 60}m"
    when 3600..86399
      "#{seconds / 3600}h"
    else
      "#{seconds / 86400}d"
    end
  end
end

# Run the watcher if called directly
if __FILE__ == $0
  ProgressWatcher.watch
end 