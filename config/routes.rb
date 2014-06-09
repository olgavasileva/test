LinkchatApp::Application.routes.draw do
  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :sessions,      only: [:new, :create, :destroy]
  resources :microposts,    only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy]
  resources :questions do
    member do
      get :responses
      post :toggle_hidden, :submit_answer
    end
  end
  root 'static_pages#home'
  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'  


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


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
