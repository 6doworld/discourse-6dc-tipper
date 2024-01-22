# frozen_string_literal: true

# Require the 'eth' gem, which provides Ethereum functionality
require 'eth'
require_relative '../../lib/discourse_6dc_tipper/eth-lib/transaction.rb'

# Define a module for the Discourse6dcTipper plugin
module Discourse6dcTipper
  # Define a controller for handling wallet-related actions
  class WalletController < ::ApplicationController
    # Define an action for displaying the index page
    def index
    end

    def fetch_wallet
        user_wallets = []
        current_user_has_account = false

        if current_user.associated_accounts.length > 0
            current_user.associated_accounts.each { |account| current_user_has_account = account[:description] if account[:name] == "siwe" }
        end

        if current_user_has_account
            user_wallets.push({
                address: current_user_has_account,
                is_private: true
            })
        end

        # Look up the current user's wallet in the database
        wallet = Wallets.where(
            user_id: current_user[:id]
        )
        
        # If the user doesn't have a wallet yet...
        if wallet.exists?
            user_wallets.push({
                address: wallet[0].wallet,
                is_private: false
            })
        end
            
        render json: { 
            status: true, 
            message: "OK.",
            data: user_wallets
        }
    end

    def send_transaction
        # Look up the current user's wallet in the database
        wallet = Wallets.find_by(
            user_id: current_user[:id]
        )
        
        if !wallet.nil?
            # Private Key, Wallet Address, RPC URL, Chain ID, Contract Address
            transaction = EthereumTransaction.new(
                wallet.privateKey,
                wallet.wallet,
                SiteSetting.network_rpc_url,
                SiteSetting.network_chain_id,
                SiteSetting.erc_20_contract 
            )

            # Use the send_transaction method to send a transaction
            tx = transaction.send_transaction(params[:recipientAddress], params[:amount])  # Send 0.001 Ether (or ERC-20 tokens)

            if tx["status"]   
                puts "=================="
                puts "WalletTransactions"
                puts "=================="
                puts "User ID: #{current_user[:id]}"
                puts "Target User ID: #{current_user[:id]}"
                puts "TX Hash: #{tx["data"]["transactionHash"]}"
                puts "TX Amount: #{params[:amount]}"
                puts "=================="

                WalletTransactions.create(
                    user_id: current_user[:id], 
                    target_user_id: current_user[:id], 
                    tx_hash: tx["data"]["transactionHash"], 
                    tx_amount: params[:amount]
                )        
            end

            render json: { 
                status: tx["status"], 
                message: "OK.",
                data: tx
            }
        else
            render json: {
                status: false,
                message: "Not allowed."
            }
        end
    end

    # Define an action for generating a new wallet
    def generate_wallet
        # Generate a new Ethereum key pair
        key = Eth::Key.new

        # Get the private key, public key, and address from the key pair
        privateKey = key.private_hex
        publicKey = key.public_hex
        walletAddress = key.address.address

        # Look up the current user's wallet in the database
        wallet = Wallets.where(
            user_id: current_user[:id]
        )

        # If the user doesn't have a wallet yet...
        if !wallet.exists?
            # ...create a new wallet for them
            new_wallet = Wallets.new(
                user_id: current_user[:id],
                wallet: walletAddress,
                privateKey: privateKey,
                # publicKey: publicKey
            )

            # Save the new wallet to the database
            new_wallet.save

            # Render a JSON response indicating that the wallet was created
            render json: { 
                status: true, 
                message: "Wallet has been created",
                data: new_wallet
            }
        else
            # If the user already has a wallet, render a JSON response indicating that the wallet already exists
            render json: { 
                status: false, 
                message: "Wallet already exists",
                data: wallet[0]
            }
        end
    end
  end
end