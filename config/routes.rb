Rails.application.routes.draw do
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

  # e.g. http://artsapi.com/id/people/jeff-widgetcorp-org
  # e.g. http://artsapi.com/id/emails/email-hash-here>
  get 'id/:resource_type/:slug', to: 'resources#show'

  # label mini API --------------------------------

  post '/label', to: 'labels#find'

  # static pages ----------------------------------

  get '/about' => 'static#about', as: :about
  get '/contact' => 'static#contact', as: :contact

  root to: 'static#home'
end
