# frozen_string_literal: true

class Wallets < ActiveRecord::Base
    self.table_name = "wallets"
    
    belongs_to :user
end