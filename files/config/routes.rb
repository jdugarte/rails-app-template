APPNAME::Application.routes.draw do

  get 'home/index', :as => 'home'
  get 'home/home' => 'home#home', :as => 'public_home'

  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout' }
  
  get 'profile/edit'      => 'profile#edit',            :as => 'edit_profile'
  put 'profile/update'    => 'profile#update',          :as => 'update_profile'
  put 'profile/password'  => 'profile#change_password', :as => 'change_password'
  get 'profile/:username' => 'profile#show',            :as => 'profile'
  
  post 'friends/:id' => 'friends#create', :as => 'friends'
  
  get 'search' => 'home#search', :as => 'search'
  
  root :to => 'home#index'

end
