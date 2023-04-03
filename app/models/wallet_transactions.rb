# frozen_string_literal: true

class WalletTransactions < ActiveRecord::Base
    self.table_name = "wallet_transactions"
    
    belongs_to :user
    belongs_to :target_user, class_name: "User", :foreign_key => 'target_user_id'
    
    def self.types
        @types ||=
          Enum.new(
            waiting: 0,
            success: 1,
            failed: 2
          )
    end

    def waiting?
        self.status == 0
    end

    def success?
        self.status == 1
    end

    def failed?
        self.status == 2
    end
end