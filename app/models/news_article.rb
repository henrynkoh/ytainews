class NewsArticle < ApplicationRecord
  has_many :generation_logs, dependent: :destroy
  
  validates :title, presence: true
  validates :original_url, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending script_ready audio_ready video_ready uploaded published failed] }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :published, -> { where(status: 'published') }
  scope :failed, -> { where(status: 'failed') }
  scope :pending_processing, -> { where(status: %w[pending script_ready audio_ready video_ready uploaded]) }
  
  def duration_formatted
    return "0:00" unless duration
    minutes = (duration / 60).to_i
    seconds = (duration % 60).to_i
    "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
  end
  
  def log_step(step, status, error_message: nil, metadata: {}, processing_time: nil, cost: nil)
    generation_logs.create!(
      step: step,
      status: status,
      error_message: error_message,
      metadata: metadata,
      processing_time_seconds: processing_time,
      cost_usd: cost
    )
  end
  
  def can_process_next_step?
    case status
    when 'pending' then true
    when 'script_ready' then script.present?
    when 'audio_ready' then audio_file_path.present?
    when 'video_ready' then video_file_path.present?
    when 'uploaded' then youtube_id.present?
    else false
    end
  end
end 