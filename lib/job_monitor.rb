#!/usr/bin/env ruby

# AI News Shorts Job Monitor
# Real-time monitoring of background jobs and article processing

require 'colorize'
require 'io/console'

class JobMonitor
  def self.start
    new.run
  end

  def initialize
    @running = true
    @refresh_interval = 2 # seconds
  end

  def run
    puts "🚀 AI News Shorts Job Monitor".colorize(:cyan).bold
    puts "=" * 50
    puts "Press 'q' to quit, 'r' to refresh, 'c' to clear".colorize(:yellow)
    puts "=" * 50
    puts

    # Start monitoring in a separate thread
    monitor_thread = Thread.new { monitor_loop }
    
    # Handle user input
    handle_input
    
    @running = false
    monitor_thread.join
  end

  private

  def monitor_loop
    while @running
      display_status
      sleep @refresh_interval
    end
  end

  def display_status
    clear_screen
    
    puts "🔄 AI News Shorts - Real-time Job Monitor".colorize(:cyan).bold
    puts "Last updated: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}".colorize(:light_black)
    puts "=" * 70
    puts

    # System Status
    display_system_status
    puts

    # Queue Status
    display_queue_status
    puts

    # Active Jobs
    display_active_jobs
    puts

    # Recent Articles
    display_recent_articles
    puts

    # Failed Jobs
    display_failed_jobs
    puts

    puts "Press 'q' to quit, 'r' to refresh now, 'c' to clear".colorize(:yellow)
  end

  def display_system_status
    puts "📊 SYSTEM STATUS".colorize(:green).bold
    puts "-" * 20

    # Rails server status
    rails_status = system("curl -s http://localhost:3000/dashboard > /dev/null 2>&1")
    rails_indicator = rails_status ? "✅ RUNNING".colorize(:green) : "❌ STOPPED".colorize(:red)
    puts "Rails Server: #{rails_indicator}"

    # Job worker status
    worker_count = `ps aux | grep -c "solid-queue-worker" | grep -v grep`.strip.to_i
    worker_indicator = worker_count > 0 ? "✅ #{worker_count} WORKERS".colorize(:green) : "❌ NO WORKERS".colorize(:red)
    puts "Job Workers: #{worker_indicator}"

    # Database status
    begin
      require_relative '../config/environment'
      db_status = ActiveRecord::Base.connection.active?
      db_indicator = db_status ? "✅ CONNECTED".colorize(:green) : "❌ DISCONNECTED".colorize(:red)
      puts "Database: #{db_indicator}"
    rescue => e
      puts "Database: ❌ ERROR".colorize(:red)
    end
  end

  def display_queue_status
    puts "📋 QUEUE STATUS".colorize(:blue).bold
    puts "-" * 20

    begin
      require_relative '../config/environment'
      
      pending_jobs = SolidQueue::Job.where(finished_at: nil).count
      completed_jobs = SolidQueue::Job.where.not(finished_at: nil).count
      failed_jobs = SolidQueue::FailedExecution.count

      puts "Pending Jobs: #{pending_jobs.to_s.colorize(pending_jobs > 0 ? :yellow : :green)}"
      puts "Completed Jobs: #{completed_jobs.to_s.colorize(:green)}"
      puts "Failed Jobs: #{failed_jobs.to_s.colorize(failed_jobs > 0 ? :red : :green)}"
      
      # Queue breakdown
      queue_breakdown = SolidQueue::Job.where(finished_at: nil)
                                      .group(:queue_name)
                                      .count
      
      if queue_breakdown.any?
        puts "\nQueue Breakdown:"
        queue_breakdown.each do |queue, count|
          puts "  #{queue}: #{count}"
        end
      end
    rescue => e
      puts "Error accessing queue data: #{e.message}".colorize(:red)
    end
  end

  def display_active_jobs
    puts "⚡ ACTIVE JOBS".colorize(:magenta).bold
    puts "-" * 20

    begin
      require_relative '../config/environment'
      
      active_jobs = SolidQueue::Job.joins("LEFT JOIN solid_queue_claimed_executions ON solid_queue_jobs.id = solid_queue_claimed_executions.job_id")
                                   .where(finished_at: nil)
                                   .where.not("solid_queue_claimed_executions.id": nil)
                                   .limit(10)

      if active_jobs.any?
        active_jobs.each do |job|
          job_class = job.class_name.split('::').last
          created_ago = time_ago(job.created_at)
          
          puts "🔄 #{job_class}".colorize(:cyan)
          puts "   Queue: #{job.queue_name} | Started: #{created_ago}"
          
          # Try to get associated article if it's a news processing job
          if job.arguments.is_a?(Array) && job.arguments.first.is_a?(Hash)
            article_id = job.arguments.first['arguments']&.first if job.arguments.first['arguments']
            if article_id
              article = NewsArticle.find_by(id: article_id)
              if article
                puts "   Article: #{article.title[0..50]}...".colorize(:light_black)
                puts "   Status: #{article.status.upcase}".colorize(status_color(article.status))
              end
            end
          end
          puts
        end
      else
        puts "No active jobs running".colorize(:green)
      end
    rescue => e
      puts "Error accessing active jobs: #{e.message}".colorize(:red)
    end
  end

  def display_recent_articles
    puts "📰 RECENT ARTICLES".colorize(:cyan).bold
    puts "-" * 20

    begin
      require_relative '../config/environment'
      
      recent_articles = NewsArticle.order(created_at: :desc).limit(5)

      if recent_articles.any?
        recent_articles.each do |article|
          status_indicator = status_indicator(article.status)
          created_ago = time_ago(article.created_at)
          
          puts "#{status_indicator} #{article.title[0..50]}..."
          puts "   Status: #{article.status.upcase}".colorize(status_color(article.status))
          puts "   Created: #{created_ago}"
          
          if article.youtube_url.present?
            puts "   YouTube: #{article.youtube_url}".colorize(:green)
          end
          puts
        end
      else
        puts "No articles found".colorize(:yellow)
      end
    rescue => e
      puts "Error accessing articles: #{e.message}".colorize(:red)
    end
  end

  def display_failed_jobs
    puts "❌ FAILED JOBS".colorize(:red).bold
    puts "-" * 20

    begin
      require_relative '../config/environment'
      
      failed_jobs = SolidQueue::FailedExecution.joins(:job)
                                               .order(created_at: :desc)
                                               .limit(3)

      if failed_jobs.any?
        failed_jobs.each do |failed_job|
          job_class = failed_job.job.class_name.split('::').last
          failed_ago = time_ago(failed_job.created_at)
          
          puts "💥 #{job_class}".colorize(:red)
          puts "   Failed: #{failed_ago}"
          puts "   Error: #{failed_job.error[0..80]}...".colorize(:light_red) if failed_job.error
          puts
        end
      else
        puts "No failed jobs ✅".colorize(:green)
      end
    rescue => e
      puts "Error accessing failed jobs: #{e.message}".colorize(:red)
    end
  end

  def handle_input
    Thread.new do
      while @running
        input = STDIN.getch
        case input.downcase
        when 'q'
          @running = false
          break
        when 'r'
          # Force refresh
          next
        when 'c'
          clear_screen
        end
      end
    end
  end

  def clear_screen
    system('clear') || system('cls')
  end

  def time_ago(time)
    seconds = Time.now - time
    
    case seconds
    when 0..59
      "#{seconds.to_i}s ago"
    when 60..3599
      "#{(seconds / 60).to_i}m ago"
    when 3600..86399
      "#{(seconds / 3600).to_i}h ago"
    else
      "#{(seconds / 86400).to_i}d ago"
    end
  end

  def status_color(status)
    case status
    when 'pending'
      :yellow
    when 'script_ready', 'audio_ready', 'video_ready'
      :blue
    when 'uploaded', 'published'
      :green
    when 'failed'
      :red
    else
      :white
    end
  end

  def status_indicator(status)
    case status
    when 'pending'
      "⏳"
    when 'script_ready'
      "📝"
    when 'audio_ready'
      "🎵"
    when 'video_ready'
      "🎬"
    when 'uploaded'
      "📺"
    when 'published'
      "✅"
    when 'failed'
      "❌"
    else
      "❓"
    end
  end
end

# Run the monitor if this file is executed directly
if __FILE__ == $0
  JobMonitor.start
end 