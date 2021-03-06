require 'resque/server'

LinkchatApp::Application.routes.draw do

  # iOS Application Redirect
  if ENV['IOS_DOWNLOAD_TRACKING_URL']
    get "/liable" => redirect(ENV['IOS_DOWNLOAD_TRACKING_URL'])
  end

  # Short Links
  get '/q/l' => 'short_links#latest_question', as: :short_latest_question

  get "/ie9proxy" => 'proxy#url'

  devise_for :users
  devise_scope :user do
    get 'campaign' => 'devise/registrations#new', as: :demo_registration
    get 'campaign_login' => 'devise/sessions#new', as: :demo_login
  end
  devise_for :partners
  devise_for :admin_users, ActiveAdmin::Devise.config

  get '/studio' => 'pages#studio' unless Rails.env.production?
  get '/welcome' => 'pages#welcome' unless Rails.env.production?
  get '/gallery' => 'pages#gallery' unless Rails.env.production?
  get '/rpush_check' => 'pages#rpush_check'

  ActiveAdmin.routes(self)

  root 'pages#welcome'
  get '/home' => 'pages#welcome', defaults: {new_web_app: true}
  get '/community(/:community_id)' => 'communities#join'
  get '/q/:uuid' => 'questions#new_response_from_uuid', as: :question_sharing
  get '/test' => 'pages#test' if Rails.env.development?
  get '/contests/exit' => 'contests#exit_contest', as: :exit_contest
  get '/contests/:uuid/sign_up' => 'contests#sign_up', as: :contest_sign_up
  post '/contests/new_user' => 'contests#new_user', as: :new_contest_user
  get '/gallery/:uuid' => 'contests#vote', as: :contest_vote
  get '/contests/:uuid/q/:quid' => 'contests#question', as: :contest_question
  post '/contests/:uuid/vote/:response_id' => 'contests#save_vote', as: :save_vote
  post '/contests/:uuid/scores' => 'contests#scores', as: :scores

  scope '/unit/:embeddable_unit_uuid', controller: 'embeddable_units' do
    get '/', action: 'start_survey', as: :embeddable_unit_start_survey
    get '/question/:question_id', action: :survey_question, as: :embeddable_unit_question
    post '/question/:question_id', action: :survey_response, as: :embeddable_unit_response
    get '/thank_you', action: :thank_you, as: :embeddable_unit_thank_you
    post '/quantcast', action: :quantcast, as: :embeddable_unit_quantcast
  end

  scope '/qp/:survey_uuid(/:unit_name)', controller: 'surveys' do
    get '/', action: 'start', as: :qp_start
    get '/q/:question_id', action: :question, as: :qp_question
    post '/q/:question_id', action: :create_response, as: :qp_create_response
    get '/thank_you', action: :thank_you, as: :qp_thank_you
    post '/quantcast', action: :quantcast, as: :qp_quantcast
    post '/q/:question_id/viewed', action: :question_viewed, as: :qp_question_viewed
  end

  resources :questions, shallow: true do
    get :preview, on: :member
    get :summary, on: :member
    get :share, on: :member
    get :results, on: :member
    post :update_targetable, on: :member
    get :skip, on: :member
    resources :responses
    resources :text_choice_responses
    resources :image_choice_responses
    resources :multiple_choice_responses
    resources :text_responses
    resources :order_responses
    resources :studio_responses
    resources :consumer_targets
    resources :enterprise_targets
  end

  resources :response_matchers, only: [:destroy]
  resources :text_response_matchers, only: [:destroy]
  resources :choice_response_matchers, only: [:destroy]
  resources :order_response_matchers, only: [:destroy]

  resources :inquiries
  resources :users do
    resources :surveys, only: [:destroy], param: :uuid
    resources :scenes, only: [:index, :new, :create]
    resources :studios, only: [:show]
    resources :segments do
      get :question_search, on: :member

      resources :response_matchers
      resources :text_response_matchers
      resources :choice_response_matchers
      resources :order_response_matchers
    end
    get :profile, on: :collection
    member do
      get :follow
      get :unfollow
      get :dashboard
      get :recent_responses
      get :recent_comments
      # get :campaigns
      get :publisher_question_packs
      get :publisher_dashboard
      get :new_campaign
      get :new_question
      get 'analytics/(:question_id)', to: 'users#analytics', as: :analytics
      get 'question_analytics/:question_id', to: 'users#question_analytics', as: :question_analytics
      get 'demographics/:question_id/(:choice_id)', to: 'users#demographics', as: :demographics
      get :question_search
      get :account
      get :avatar
      resources :listicles, param: :listicle_id do
        collection do
          post 'image_upload' => 'listicles#image_upload'
          get 'search' => 'listicles#search', as: :search
        end
        member do
          patch 'advanced_form' => 'advanced_listicles#update', as: :advanced_form
          get 'basic_form' => 'listicles#basic_form'
          get 'details' => 'listicles#details', as: :details
          resource :analytics, only: [:show], controller: :listicle_analytics, as: :listicle_analytics
          resources :questions, only: [:update, :edit], param: :question_id, controller: :listicle_questions, as: :listicle_questions
        end
      end
      get :behavioural_report, as: :behavioural_report
      get :cognitive_report, as: :cognitive_report
      resources :campaigns, param: :survey_id, only: [:index, :show]
      resources :image_search, only: [:create]
    end
  end

  post 'answer_listicle_question/:question_id' => 'listicles#answer_question', as: :answer_listicle_question
  get 'listicle/:id' => 'listicles#embed', as: :show_listicle
  post 'listicle/:id/quantcast' => 'listicles#quantcast', as: :listicle_quantcast

  resources :groups

  resources :group_members do
    delete '/' => 'group_members#destroy', on: :collection
  end

  resources :communities do
    get :invite, on: :member
  end

  resources :community_members do
    delete '/' => 'community_members#destroy', on: :collection
  end

  resources :question_types

  resources :yes_no_questions do
    get :target, on: :member
    post :enable, on: :member
    resources :comments, only: :create
  end

  resources :order_questions do
    get :target, on: :member
    post :enable, on: :member
    resources :comments, only: :create
  end

  resources :text_questions do
    get :target, on: :member
    post :enable, on: :member
    resources :comments, only: :create
  end

  resources :multiple_choice_questions do
    get :target, on: :member
    post :enable, on: :member
    resources :comments, only: :create
  end

  resources :image_choice_questions do
    get :target, on: :member
    post :enable, on: :member
    resources :comments, only: :create
  end

  resources :text_choice_questions do
    get :target, on: :member
    post :enable, on: :member
    resources :comments, only: :create
  end

  resources :background_images
  resources :question_images
  resources :choice_images
  resources :order_choice_images


  mount TwoCents::API => '/'
  mount GrapeSwaggerRails::Engine => '/docs'

  authenticate :admin_user do
    mount Resque::Server.new, at: "/jobs"
  end

  # OmniAuth Callbacks
  constraints(provider: /#{Authentication::PROVIDERS.join('|')}/) do
    match '/auth/:provider/setup', to: 'omniauth#setup', via: [:get, :post]
    match '/auth/:provider/callback', to: 'omniauth#callback', via: [:get, :post]
    get '/auth/failure', to: 'omniauth#failure'
  end
end
