ActionController::Routing::Routes.draw do |map|

  map.connect '/routes/:transport_type', :controller => 'routes'
  map.connect '/routes/:transport_type.:format', :controller => 'routes'

  map.connect '/routes/:transport_type/headsigns/*id', :controller => 'headsigns', :action => 'show'


  map.connect '/trains/:line_name', :controller => 'trains', :action => 'index'

  map.connect '/trips', :controller => 'trips'
  map.connect '/trips.:format', :controller => 'trips'
  map.connect '/trips/:id', :controller => 'trips', :action => "show"

  map.connect '/stop_arrivals', :controller => 'stop_arrivals', :action => 'index'

  map.connect '/alerts', :controller => 'alerts', :action => 'index'
  map.connect '/alerts.:format', :controller => 'alerts', :action => 'index'

  #map.resources :tweets
  map.connect '/tweets/:search', :controller => 'tweets'

  map.connect '/alerts/:guid', :controller => 'alerts', :action => 'show'
  map.connect '/help/:target_controller/:transport_type', :controller => 'help', :action => 'show'
  map.connect '/about/:action', :controller => 'about'
  map.connect '/support/:action', :controller => 'support'

  # web kit version

  map.connect '/mobile', :controller => 'main'
  map.connect '/main', :controller => 'main'

  map.root :controller => 'home'


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
