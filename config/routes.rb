Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :api, only: [:process_logs] do
    collection do
      post "process-logs" => "api#process_logs"
    end
  end
end
