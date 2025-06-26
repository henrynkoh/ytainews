class CreateNewsArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :news_articles do |t|
      # Basic info
      t.string :title, null: false
      t.text :content
      t.text :summary
      t.string :original_url, null: false
      t.string :source
      t.datetime :published_at
      
      # Generated content
      t.text :script
      t.string :hook
      t.json :key_points, default: []
      
      # File paths
      t.string :audio_file_path
      t.string :video_file_path
      t.string :background_image_path
      
      # YouTube info
      t.string :youtube_id
      t.string :youtube_url
      t.json :youtube_metadata, default: {}
      
      # Status tracking
      t.string :status, default: 'pending'
      # pending -> script_ready -> audio_ready -> video_ready -> uploaded -> published
      
      # Analytics
      t.integer :views, default: 0
      t.integer :likes, default: 0
      t.integer :comments, default: 0
      t.float :duration
      t.float :watch_time_percentage
      
      t.timestamps
    end
    
    add_index :news_articles, :original_url, unique: true
    add_index :news_articles, :status
    add_index :news_articles, :published_at
    add_index :news_articles, :source
    add_index :news_articles, :created_at
  end
end 