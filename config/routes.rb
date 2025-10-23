Rails.application.routes.draw do
  root "surveys#index"

  resources :surveys do
    member do
      get  :branching
      post :update_branching
      get  :take
      post :submit
      get  :analytics   # <-- adding analytics
    end

    resources :questions, except: [:index, :show]
    resources :responses, only: [:create]
  end

  resources :responses, only: [] do
    collection { post :start }
  end
end