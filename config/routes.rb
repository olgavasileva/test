require 'resque/server'

LinkchatApp::Application.routes.draw do
  match "/404" => "errors#error404", via: [ :get, :post, :patch, :delete ]
  match "/500" => "errors#error500", via: [ :get, :post, :patch, :delete ]

  # iOS Application Redirect
  if ENV['IOS_DOWNLOAD_TRACKING_URL']
    get "/liable" => redirect(ENV['IOS_DOWNLOAD_TRACKING_URL'])
  end

  # Short Links
  get '/q/l' => 'short_links#latest_question'

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
  get '/home' => 'pages#welcome', defaults: { new_web_app: true }
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

  resources :questions, shallow:true do
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
    resources :targets
    resources :enterprise_targets
  end

  resources :response_matchers, only: [:destroy]
  resources :text_response_matchers, only: [:destroy]
  resources :choice_response_matchers, only: [:destroy]
  resources :order_response_matchers, only: [:destroy]

  resources :inquiries
  resources :users do
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
      get :campaigns
      get :new_campaign
      get 'analytics/(:question_id)', to:'users#analytics', as: :analytics
      get 'question_analytics/:question_id', to:'users#question_analytics', as: :question_analytics
      get 'demographics/:question_id/(:choice_id)', to:'users#demographics', as: :demographics
      get :question_search
      get :account
      get :avatar
    end
  end

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


  mount TwoCents::API =>'/'
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
