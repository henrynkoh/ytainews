Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by uptime monitors like UptimeRobot or Pingdom.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#index"

  # Dashboard routes
  get 'dashboard', to: 'dashboard#index'
  post 'dashboard/start_crawling', to: 'dashboard#start_crawling'
  post 'dashboard/process_pipeline', to: 'dashboard#process_pipeline'
  get 'dashboard/logs', to: 'dashboard#logs'
  get 'dashboard/progress', to: 'dashboard#progress'
  post 'dashboard/:id/retry', to: 'dashboard#retry_article', as: 'retry_article_dashboard'

  # API routes
  namespace :api do
    namespace :v1 do
      post 'crawler/crawl', to: 'crawler#crawl'
      post 'pipeline/process', to: 'pipeline#process'
    end
  end
end 