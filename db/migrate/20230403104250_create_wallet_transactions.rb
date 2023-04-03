# frozen_string_literal: true

class CreateWalletTransactions < ActiveRecord::Migration[7.0]
    def change                
        create_table :wallet_transactions do |t|
            t.integer :user_id, null: false
            t.integer :target_user_id, null: false
            t.text :tx_hash
            t.text :tx_amount
            t.integer :status, default: 1
            t.timestamps
        end
        
        add_index :wallet_transactions, :user_id
        add_index :wallet_transactions, :target_user_id
    end
end