# frozen_string_literal: true

Discourse6dcTipper::Engine.routes.draw do
  get '/auth' => 'auth#index'
  get '/message' => 'auth#message'

  get '/gw' => 'wallet#generate_wallet'
  get '/fw' => 'wallet#fetch_wallet'
  post '/st' => 'wallet#send_transaction'

  get '/wallets' => 'transaction#has_wallet'
  get '/transactions' => 'transaction#get_transactions'
  post '/transaction' => 'transaction#create_transaction'
end
