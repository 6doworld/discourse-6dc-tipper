# frozen_string_literal: true

class CreateWallets < ActiveRecord::Migration[7.0]
    def change                
        create_table :wallets do |t|
            t.references :user, null: false, foreign_key: true
            
            t.text :wallet
            t.text :privateKey
            t.timestamps
        end
        
        # add_index :wallets, :user_id
    end
end