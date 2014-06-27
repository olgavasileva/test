LinkchatApp::Application.routes.draw do
  devise_for :users
  devise_for :partners
  devise_for :admin_users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

  root 'static_pages#home'

  resources :inquiries

  mount TwoCents::API =>'/'
  get "/docs" => 'docs#index'

  namespace :api, :defaults => { :format => :json } do
    resources :users do
      member do
        post :list_index, :following, :followers, :devices, :microposts, :follow, :unfollow, :register, :login, :autofriend_all_users, :friends
      end
    end
    resources :sessions,      only: [:create]
    resources :devices,       only: [:create]
    resources :microposts,    only: [:create, :destroy] do
      member do
        post :user_feed
      end
    end
    resources :questions do
      member do
        post :next10, :results, :next10WithPacks, :ask_question_type_1, :ask_question_type_2, :ask_question_type_3, :ask_question_type_4, :ask_question_type_5, :questions_asked, :questions_answered, :share_question, :results_v2, :question_feed
      end
    end
    resources :answers do
      member do
        post :answer_question_type_1, :answer_question_type_2, :answer_question_type_3, :answer_question_type_4, :answer_question_type_5
      end
    end

    match 'users/register', to: 'users#register', :via => 'post'
    match 'users/login', to: 'users#login', :via => 'post'
    match 'users/list_index', to: 'users#list_index', :via => 'post'
    match 'users/autofriend_all_users', to: 'users#autofriend_all_users', :via => 'post'
    match 'users/friends', to: 'users#friends', :via => 'post'
    match 'microposts/user_feed', to: "microposts#user_feed", :via => 'post'
    match 'questions/next10', to: "questions#next10", :via => 'post'
    match 'questions/next10WithPacks', to: "questions#next10WithPacks", :via => 'post'
    match 'questions/ask_question_type_1', to: "questions#ask_question_type_1", :via => 'post'
    match 'questions/ask_question_type_2', to: "questions#ask_question_type_2", :via => 'post'
    match 'questions/ask_question_type_3', to: "questions#ask_question_type_3", :via => 'post'
    match 'questions/ask_question_type_4', to: "questions#ask_question_type_4", :via => 'post'
    match 'questions/ask_question_type_5', to: "questions#ask_question_type_5", :via => 'post'
    match 'questions/questions_asked', to: "questions#questions_asked", :via => 'post'
    match 'questions/questions_answered', to: "questions#questions_answered", :via => 'post'
    match 'questions/share_question', to: "questions#share_question", :via => 'post'
    match 'questions/shared_with_me', to: "questions#shared_with_me", :via => 'post'
    match 'questions/question_feed', to: "questions#question_feed", :via => 'post'
    match 'answers/answer_question_type_1', to: "answers#answer_question_type_1", :via => 'post'
    match 'answers/answer_question_type_2', to: "answers#answer_question_type_2", :via => 'post'
    match 'answers/answer_question_type_3', to: "answers#answer_question_type_3", :via => 'post'
    match 'answers/answer_question_type_4', to: "answers#answer_question_type_4", :via => 'post'
    match 'answers/answer_question_type_5', to: "answers#answer_question_type_5", :via => 'post'
  end
end
