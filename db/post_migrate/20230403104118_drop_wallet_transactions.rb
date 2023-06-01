class DropWalletTransactions < ActiveRecord::Migration[7.0]
    def down
        drop_table :wallet_transactions
    end
end
