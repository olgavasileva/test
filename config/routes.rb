LinkchatApp::Application.routes.draw do
  match "/404" => "errors#error404", via: [ :get, :post, :patch, :delete ]
  match "/500" => "errors#error500", via: [ :get, :post, :patch, :delete ]

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
  get '/community' => 'pages#welcome' # Temporary fix for broken community link
  get '/q/:uuid' => 'questions#new_response_from_uuid', as: :question_sharing
  get '/question' => 'users#first_question'
  get '/test' => 'pages#test' if Rails.env.development?
  get '/contests/exit' => 'contests#exit_contest', as: :exit_contest
  get '/contests/:uuid/sign_up' => 'contests#sign_up', as: :contest_sign_up
  post '/contests/new_user' => 'contests#new_user', as: :new_contest_user
  get '/gallery/:uuid' => 'contests#vote', as: :contest_vote
  get '/contests/:uuid/q/:quid' => 'contests#question', as: :contest_question
  post '/contests/:uuid/vote/:response_id' => 'contests#save_vote', as: :save_vote
  post '/contests/:uuid/scores' => 'contests#scores', as: :scores

  resources :questions, shallow:true do
    get :preview, on: :member
    get :summary, on: :member
    get :share, on: :member
    get :results, on: :member
    post :update_targetable, on: :member
    resources :responses
    resources :text_choice_responses
    resources :image_choice_responses
    resources :multiple_choice_responses
    resources :text_responses
    resources :order_responses
    resources :studio_responses
    resources :targets
    resources :enterprise_targets

    resources :skipped_items
  end

  resources :response_matchers, only: [:destroy]
  resources :text_response_matchers, only: [:destroy]
  resources :choice_response_matchers, only: [:destroy]
  resources :order_response_matchers, only: [:destroy]

  resources :inquiries
  resources :users do
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
  end

  resources :order_questions do
    get :target, on: :member
    post :enable, on: :member
  end

  resources :text_questions do
    get :target, on: :member
    post :enable, on: :member
  end

  resources :multiple_choice_questions do
    get :target, on: :member
    post :enable, on: :member
  end

  resources :image_choice_questions do
    get :target, on: :member
    post :enable, on: :member
  end

  resources :text_choice_questions do
    get :target, on: :member
    post :enable, on: :member
  end

  resources :background_images
  resources :question_images
  resources :choice_images
  resources :order_choice_images


  mount TwoCents::API =>'/'
  mount GrapeSwaggerRails::Engine => '/docs'

  # namespace :api, :defaults => { :format => :json } do
  #   resources :users do
  #     member do
  #       post :list_index, :following, :followers, :devices, :microposts, :follow, :unfollow, :register, :login, :autofriend_all_users, :friends
  #     end
  #   end
  #   resources :sessions,      only: [:create]
  #   resources :devices,       only: [:create]
  #   resources :microposts,    only: [:create, :destroy] do
  #     member do
  #       post :user_feed
  #     end
  #   end
  #   resources :questions do
  #     member do
  #       post :next10, :results, :next10WithPacks, :ask_question_type_1, :ask_question_type_2, :ask_question_type_3, :ask_question_type_4, :ask_question_type_5, :questions_asked, :questions_answered, :share_question, :results_v2, :question_feed
  #     end
  #   end
  #   resources :answers do
  #     member do
  #       post :answer_question_type_1, :answer_question_type_2, :answer_question_type_3, :answer_question_type_4, :answer_question_type_5
  #     end
  #   end

  #   match 'users/register', to: 'users#register', :via => 'post'
  #   match 'users/login', to: 'users#login', :via => 'post'
  #   match 'users/list_index', to: 'users#list_index', :via => 'post'
  #   match 'users/autofriend_all_users', to: 'users#autofriend_all_users', :via => 'post'
  #   match 'users/friends', to: 'users#friends', :via => 'post'
  #   match 'microposts/user_feed', to: "microposts#user_feed", :via => 'post'
  #   match 'questions/next10', to: "questions#next10", :via => 'post'
  #   match 'questions/next10WithPacks', to: "questions#next10WithPacks", :via => 'post'
  #   match 'questions/ask_question_type_1', to: "questions#ask_question_type_1", :via => 'post'
  #   match 'questions/ask_question_type_2', to: "questions#ask_question_type_2", :via => 'post'
  #   match 'questions/ask_question_type_3', to: "questions#ask_question_type_3", :via => 'post'
  #   match 'questions/ask_question_type_4', to: "questions#ask_question_type_4", :via => 'post'
  #   match 'questions/ask_question_type_5', to: "questions#ask_question_type_5", :via => 'post'
  #   match 'questions/questions_asked', to: "questions#questions_asked", :via => 'post'
  #   match 'questions/questions_answered', to: "questions#questions_answered", :via => 'post'
  #   match 'questions/share_question', to: "questions#share_question", :via => 'post'
  #   match 'questions/shared_with_me', to: "questions#shared_with_me", :via => 'post'
  #   match 'questions/question_feed', to: "questions#question_feed", :via => 'post'
  #   match 'answers/answer_question_type_1', to: "answers#answer_question_type_1", :via => 'post'
  #   match 'answers/answer_question_type_2', to: "answers#answer_question_type_2", :via => 'post'
  #   match 'answers/answer_question_type_3', to: "answers#answer_question_type_3", :via => 'post'
  #   match 'answers/answer_question_type_4', to: "answers#answer_question_type_4", :via => 'post'
  #   match 'answers/answer_question_type_5', to: "answers#answer_question_type_5", :via => 'post'
  # end
end
