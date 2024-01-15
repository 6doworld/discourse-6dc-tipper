require 'ethereum.rb'

class EthereumTransaction
    def initialize(private_key, wallet_address, contract_address = nil)
        @private_key = private_key
        @wallet_address = wallet_address
        @client = Ethereum::HttpClient.new('https://mainnet.infura.io/v3/9112f4a5ae1e4b9d8c721cd5f30dd5b3')
      
        if contract_address
          @contract = Ethereum::Contract.create({
            file: "./erc20_abi.json", 
            address: contract_address, 
            client: @client
          })
        end
    end

    def send_transaction(recipient_address, ether_value)
      wei_value = (ether_value.to_f * (10**18)).to_i  # Convert Ether to Wei
    
      if @contract.address
        # This is an ERC-20 token transaction
        data = @contract.call(:transfer, recipient_address, wei_value)
        to = @contract.address
      else
        # This is a standard Ethereum transaction
        data = ""
        to = recipient_address
      end
    
      tx = Ethereum::Transaction.new({
        data: data,
        gas_limit: @client.eth_estimate_gas(from: @wallet_address, to: to, value: wei_value),
        gas_price: @client.gas_price,
        nonce: @client.get_transaction_count(@wallet_address),
        to: to,
        value: wei_value
      })
    
      tx.sign(@private_key)
      @client.eth_send_raw_transaction(tx.hex)
    end
end
