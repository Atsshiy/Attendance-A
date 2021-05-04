Rails.application.routes.draw do
  get 'offices/index'

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :offices
  resources :users do
    collection {post 'import'}
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      # 勤怠変更申請
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      # １ヶ月承認
      patch 'attendances/update_month_approval'
      # 確認のshowページ
      get 'verifacation'
    end
    collection do
      get 'working_list'
    end
    resources :attendances, only: [:update] do
      member do
        # 残業申請モーダル
        get 'edit_overwork_request'
        patch 'update_overwork_request'
        # 残業申請お知らせモーダル
        get 'edit_notice_overwork'
        patch 'update_notice_overwork'
        # 勤怠変更お知らせモーダル
        get 'edit_one_month_notice'
        patch 'update_one_month_notice'
        
        #１ヶ月承認モーダル
        get 'edit_month_approval_notice'
        patch 'update_month_approval_notice'
        
        # 勤怠ログ
        get 'log'
      end
    end
  end
end