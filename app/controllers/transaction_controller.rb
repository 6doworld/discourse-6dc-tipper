# frozen_string_literal: true

module Discourse6dcTipper
  class TransactionController < ::ApplicationController
    requires_login

    def index
    end

    def create_transaction
        target_id = params[:target_id].to_i
        user = User.find_by(id: target_id)

        if (user[:id] == current_user[:id])
            return render json: { 
                status: false,
                message: I18n.t("error.user_tip")
            }
        end
        
        amount = params[:amount].to_s
        transaction_hash = params[:transaction_hash].to_s

        created_transaction = WalletTransactions.create(
            user_id: current_user[:id], 
            target_user_id: target_id, 
            tx_hash: transaction_hash, 
            tx_amount: amount
        )

        PostCreator.create(
            Discourse.system_user,
            target_usernames: user[:username],
            archetype: Archetype.private_message,
            subtype: TopicSubtype.system_message,
            title: I18n.t("success.sent_tip", {
                username: current_user[:username],
                amount: amount.to_s,
                currency: SiteSetting.currency
            }),
            raw: I18n.t("success.sent_tip", {
                username: current_user[:username],
                amount: amount.to_s,
                currency: SiteSetting.currency
            })
        )

        render json: { 
            status: true,
            message: "",
            data: created_transaction 
        }
    end

    def get_transactions        
        target_id = params[:target_id].to_i

        # Get latest transactions first
        transactions = WalletTransactions.where(
            user_id: [current_user[:id], target_id]
        ).order('created_at DESC')

        render json: { 
            status: true, 
            message: "",
            data: transactions 
        }
    end

    def has_wallet
        target_user = params[:target_id].to_i
        user = User.find_by(id: target_user)
        has_account = false
        current_user_has_account = false

        if user && user.associated_accounts.length > 0
            user.associated_accounts.each { |account| has_account = account[:description] if account[:name] == "siwe" }
        end

        if current_user.associated_accounts.length > 0
            current_user.associated_accounts.each { |account| current_user_has_account = account[:description] if account[:name] == "siwe" }
        end

        if has_account == false
            PostCreator.create(
                Discourse.system_user,
                target_usernames: user[:username],
                archetype: Archetype.private_message,
                subtype: TopicSubtype.system_message,
                title: I18n.t("error.enable_wallet", { username: current_user[:username], url: "/u/#{user[:username]}/preferences/account" }),
                raw: I18n.t("error.enable_wallet", { username: current_user[:username], url: "/u/#{user[:username]}/preferences/account" })
            )
        end

        render json: { 
            status: has_account && current_user_has_account,
            message: "", 
            data: { 
                target_has_wallet: has_account, 
                user_has_wallet: current_user_has_account 
            } 
        }
    end
  end
end
