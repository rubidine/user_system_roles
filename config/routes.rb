ActionController::Routing::Routes.draw do |map|
  map.connect '/users/inform_norole',
              :controller => 'users', :action => 'inform_norole'
end
