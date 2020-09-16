SampleApp::Application.routes.draw do
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

  # ---------------------------------------------------------------------------------------------------------------
  # ユーザーのURLを生成するための多数の名前付きルートに従って、RESTfulなUsersリソースで必要となる全てのアクションが利用できるようになる
  # ---------------------------------------------------------------------------------------------------------------
  # HTTPリクエスト |   URL      | アクション | 名前付きルート           | 用途
  # GET            /users         index      users_path             全てのユーザーを表示するページ
  # GET            /users/1       show       user_path(user)        特定のユーザー(id=1)を表示するページ
  # GET            /users/new     new        new_user_path          ユーザーを新規作成するページ（ユーザー登録）
  # POST           /users         create     users_path             ユーザーを作成するアクション
  # GET            /users/1/edit  edit       edit_user_path(user)   ユーザー(id=1)を編集するページ
  # PATCH          /users/1       update     user_path(user)        ユーザー(id=1)を変更するアクション
  # DELETE         /users/1       destroy    user_path(user)        ユーザー(id=1)を削除するアクション
  # ---------------------------------------------------------------------------------------------------------------
  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :microposts, only: [:create, :destroy]

  # root用の記述方式で、自動的にコントローラーとビューで使用する名前付きルートを生成する
  # 生成される名前月ルートは以下
  # root_path => '/'
  # root_url => 'http://localhost:3000/'
  root 'static_pages#home'

  # match '/xxx' は自動的にコントローラーとビューで使用する名前付きルートを生成する
  # 生成される名前付きルートは以下
  # xxx_path => '/xxx'
  # xxx_url => 'http://localhost:3000/xxx'
  match '/signup', to: 'users#new', via: 'get'
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'
  match '/help', to: 'static_pages#help', via: 'get'
  match '/about', to: 'static_pages#about', via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
end
