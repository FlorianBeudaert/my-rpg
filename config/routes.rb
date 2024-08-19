Rails.application.routes.draw do
  root 'users#login'
  get 'users/new'

  resources :users, only: [:create]
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'


  get '/login', to: 'users#login', as: 'login'
  post '/login', to: 'users#create_session'

  get '/logout', to: 'users#logout', as: 'logout'

  get '/profile', to: 'users#profile', as: 'profile'
  post '/profile/add_life', to: 'users#add_life', as: 'add_life'
  post '/profile/add_strength', to: 'users#add_strength', as: 'add_strength'
  post '/profile/equip_item', to: 'users#equip_item', as: 'equip_item'
  post '/profile/unequip_item', to: 'users#unequip_item', as: 'unequip_item'

  resources :quests, only: [:create, :show]
  resources :steps, only: [:create]
  get '/admin/quests', to: 'quests#panel', as: 'admin_quests'
  get '/admin/quests/:id', to: 'quests#show', as: 'admin_quest'
  delete '/admin/quests/:id', to: 'quests#delete', as: 'delete_quest'
  delete '/admin/steps/:id', to: 'steps#delete', as: 'delete_step'

  get '/quests', to: 'quests#list', as: 'quests_list'
  post '/quests/:id/choose', to: 'quests#choose', as: 'choose_quest'
  post '/quests/:id/cancel', to: 'quests#cancel', as: 'cancel_quest'

  get '/adventure', to: 'adventure#index', as: 'adventure'
  get '/adventure/step', to: 'adventure#step', as: 'adventure_step'
  post '/adventure/step/answer', to: 'adventure#answer', as: 'adventure_answer'
  get '/adventure/fight', to: 'adventure#fight', as: 'adventure_fight'
  post '/adventure/attack', to: 'adventure#attack', as: 'adventure_attack'
  get '/adventure/npc_attack', to: 'adventure#npc_attack', as: 'adventure_npc_attack'
  get 'adventure/congratulations', to: 'adventure#congratulations', as: 'congratulations_adventure'
  post '/adventure/add_item', to: 'adventure#add_item', as: 'add_item'

  get "up" => "rails/health#show", as: :rails_health_check
end