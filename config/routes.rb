Rails.application.routes.draw do
  devise_for :users
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
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

  # keywords --------------------------------------

  # keyword category
  get 'id/keywords/category/:slug', to: 'keywords#category'

  # keyword sub category
  get 'id/keywords/subcategory/:slug', to: 'keywords#subcategory'

  # keyword
  get 'id/keywords/keyword/:slug', to: 'keywords#show'

  # linked data resources -------------------------

  # e.g. http://data.artsapi.com/id/people/jeff-widgetcorp-org
  # e.g. http://data.artsapi.com/id/emails/email-hash-here>
  get 'id/:resource_type/:slug', to: 'resources#show'

  # label mini API --------------------------------

  post '/get_label', to: 'labels#find'
  post '/edit_label', to: 'labels#edit'

  # connections mini API --------------------------

  get '/get_connections_for_chart', to: 'connections#distribution'
  get '/get_connections_for_graph', to: 'connections#visualise_person'
  get '/get_organisation_graph', to: 'connections#visualise_organisation'
  post '/get_connections', to: 'connections#find'
  post '/generate_connections', to: 'connections#generate'

  # uploads mini API ------------------------------

  get '/uploads', to: 'uploads#index', as: :uploads
  get '/authorize_dropbox', to: 'uploads#authorize', as: :authorize_dropbox
  get '/dropbox_callback', to: 'uploads#dropbox_callback', as: :dropbox_callback
  post '/create_client_and_fetch_file', to: 'uploads#create_client_and_fetch_file', as: :fetch_file
  post '/process_data', to: 'uploads#process_data', as: :process_data

  # bulk tagging ----------------------------------

  get '/collection_tagging', to: 'collections#show', as: :collection_tagging

  # organisations ---------------------------------

  post '/organisations/update', to: 'organisations#update', as: :update_organisation

  # people ----------------------------------------

  post '/people/update', to: 'people#update', as: :update_person

  # static pages ----------------------------------

  get '/about' => 'static#about', as: :about
  get '/contact' => 'static#contact', as: :contact
  get '/home' => 'static#home', as: :home

  root to: 'devise/sessions#new'

  authenticated :user do
    root to: 'static#home', as: :logged_in_root
  end

end
