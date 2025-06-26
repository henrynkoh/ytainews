class GenerationLog < ApplicationRecord
  belongs_to :news_article
  
  validates :step, presence: true
  validates :status, inclusion: { in: %w[processing success failed] }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :failed, -> { where(status: 'failed') }
  scope :successful, -> { where(status: 'success') }
  scope :for_step, ->(step) { where(step: step) }
end 