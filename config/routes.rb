Rails.application.routes.draw do
  get 'offices/index'

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :users do
    collection do
      post 'import'
      resources :offices
    end
    member do
      get 'attendances/edit_overwork_request'
      patch 'attendances/update_overwork_request'
      
      get 'attendances/edit_notice_overwork'
      patch 'attendances/update_notice_overtime'
      
      get 'attendances/edit_monthly'
      patch 'attendances/update_edit_monthly'
      
      get 'attendances/edit_notice_working'
      patch 'attendances/update_notice_working'
      
      get 'edit_basic_info'
      patch 'update_basic_info'
      
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
    end
    collection do
      get 'working_list'
    end
    resources :attendances, only: :update
  end
end
