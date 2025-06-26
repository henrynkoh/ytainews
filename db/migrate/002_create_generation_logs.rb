class CreateGenerationLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :generation_logs do |t|
      t.references :news_article, null: false, foreign_key: true
      t.string :step, null: false # crawl, script, audio, video, upload
      t.string :status, null: false # processing, success, failed
      t.text :error_message
      t.json :metadata, default: {}
      t.integer :processing_time_seconds
      t.decimal :cost_usd, precision: 8, scale: 4
      
      t.timestamps
    end
    
    add_index :generation_logs, [:news_article_id, :step]
    add_index :generation_logs, :status
    add_index :generation_logs, :created_at
  end
end 