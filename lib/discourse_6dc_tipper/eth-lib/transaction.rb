require 'eth'
require 'net/http'
require 'uri'
require 'json'

class EthereumTransaction
  def initialize(private_key, wallet_address, rpc_url, chain_id = 1, contract_address = '')
    @private_key_plain = private_key
    @wallet_address = wallet_address
    @rpc_url = rpc_url
    @chain_id = chain_id
    @contract_address = contract_address
  end

  def send_transaction(to, ether_value)
    uri = URI("http://localhost:4738/transfer")
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  
    begin
      if !@contract_address.empty?
        request.body = {
          type: "erc20",
          data: {
            debug: true,
            contractAddress: @contract_address,
            providerUrl: @rpc_url,
            chainId: @chain_id,
            recipientAddress: to,
            senderAddress: @wallet_address,
            senderPrivateKey: @private_key_plain,
            amount: ether_value
          }
        }.to_json
      else
        request.body = {
          type: "eth",
          data: {
            debug: true,
            providerUrl: @rpc_url,
            chainId: @chain_id,
            recipientAddress: to,
            senderAddress: @wallet_address,
            senderPrivateKey: @private_key_plain,
            amount: ether_value
          }
        }.to_json
      end

      puts request.body
  
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: false) do |http|
        http.request(request)
      end
  
      result = JSON.parse(response.body)

      result
    rescue => e
      puts "An error occurred: #{e.message}"
    end
  end  
end
