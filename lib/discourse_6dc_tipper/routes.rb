# frozen_string_literal: true

Discourse6dcTipper::Engine.routes.draw do
  get '/auth' => 'auth#index'
  get '/message' => 'auth#message'
  get '/wallets' => 'transaction#has_wallet'
  get '/transactions' => 'transaction#get_transactions'
  post '/transaction' => 'transaction#create_transaction'
end
