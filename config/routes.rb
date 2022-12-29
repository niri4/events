Rails.application.routes.draw do
  # -- api
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do

      # Group Events
      resources :group_events, except: [:new, :edit]
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
