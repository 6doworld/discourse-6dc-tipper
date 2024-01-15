require 'eth'
require 'net/http'
require 'uri'
require 'json'

class EthereumTransaction
  def initialize(private_key, wallet_address, rpc_url, chain_id = 1, contract_address = nil)
    @erc20_abi = JSON.parse('[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"subtractedValue","type":"uint256"}],"name":"decreaseAllowance","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"addedValue","type":"uint256"}],"name":"increaseAllowance","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"}]');
    @private_key_plain = private_key
    @private_key = Eth::Key.new priv: @private_key
    @wallet_address = wallet_address
    @rpc_url = rpc_url
    @chain_id = chain_id
    @contract_address = contract_address
  end

  def send_transaction(to, ether_value)
    wei_value = (ether_value.to_f * (10**18)).to_i  # Convert Ether to Wei
  
    if @contract_address
        # puts "\n\n\n"
        # puts "========================"
        # puts "Custom Contract Testing"
        # puts "========================"
        # @contract = Eth::Contract.from_abi(name: "GBP", address: @contract_address, abi: @erc20_abi)
        # puts @contract
        
        # # result = @contract.balanceOf('0xbA1eEf74b0013d074346920e0C3356471e063F9F')
        # # puts "Balance: #{result}"

        # client = Eth::Client.create(@rpc_url)
        # puts client.inspect
        # puts "Chain ID: #{client.chain_id} | Contract Chain ID: #{@contract.chain_id}"
        # # tx1 = client.get_balance(@wallet_address)
        # # tx = client.transfer_and_wait(to, 1, sender_key: @private_key, legacy: true)
        
        # puts "Contract Name: #{client.call(@contract, "name")}"
        # puts "Contract Symbol: #{client.call(@contract, "symbol")}"
        # puts "Contract Total Supply: #{client.call(@contract, "totalSupply")}"
        # puts "Contract Wallet Balance: #{client.call(@contract, "balanceOf", @wallet_address)}"
        
        # tx = client.transfer_erc20_and_wait(@contract, to, 0, sender_key: @private_key, legacy: true, gas_limit: 21578)
        # # tx = client.transact_and_wait(@contract, "transfer", address: to, amount: 0, sender_key: @private_key, legacy: true, gas_limit: 21578)
        # puts "Tx: #{tx}"
        # # @contract.transfer()
        # puts "========================"
        # puts "\n\n\n"

        # This is an ERC-20 token transaction
        function_signature = ::Eth::Util.keccak256("transfer(address,uint256)")[0...10]
        address_padded = ::Eth::Util.zpad(decode_hex(to.sub(/^0x/, '')), 32)
        value_padded = ::Eth::Util.zpad(int_to_base256(wei_value), 32)
        data = '0x' + (function_signature + address_padded + value_padded).unpack1('H*')
        # gas_limit = estimate_gas(@contract_address, 0, data)  # Use 0 value for token transfer
        gas_limit = 26178

        puts "Sending ERC-20 token transaction:"
        puts "  To: #{@contract_address}"
        puts "  Wei Value: 0"  # For ERC-20 token, the value is set in the data field
        puts "  Data: #{data}"
        puts "  Gas Limit: #{gas_limit}"
    
        # Override 'to' with the contract address
        to = @contract_address
    else
        # This is a standard Ethereum transaction
        data = ""
        gas_limit = estimate_gas(to, wei_value)
    end
  
    nonce = get_nonce
    gas_price = get_gas_price
  
    tx = Eth::Tx.new({
      data: data,
      gas_limit: gas_limit,
      gas_price: gas_price,
      nonce: nonce,
      to: to,
      value: wei_value,
      chain_id: @chain_id
    })
  
    tx.sign @private_key
  
    send_raw_transaction(tx.hex)
  end

  private

  def decode_hex(hex)
    [hex].pack('H*')
  end

  def int_to_base256(int)
    int.to_s(16).rjust(64, '0').scan(/../).map(&:hex).pack('c*')
  end  

  def get_nonce
    uri = URI(@rpc_url)
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.body = {
      jsonrpc: "2.0",
      method: "eth_getTransactionCount",
      params: [@wallet_address, "latest"],
      id: 1
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    puts "====================="
    puts "Get Nonce"
    puts "====================="
    puts response.body
    puts "====================="

    result = JSON.parse(response.body)["result"]
    result.hex
  end

  def estimate_gas(to, value, data = "")
    uri = URI(@rpc_url)
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.body = {
        jsonrpc: "2.0",
        method: "eth_estimateGas",
        params: [{from: @wallet_address, to: to, value: '0x' + value.to_s(16), data: data}],
        id: 1
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    puts "====================="
    puts "Estimate Gas Price"
    puts "====================="
    puts response.body
    puts "====================="
        
    result = JSON.parse(response.body)["result"]
    result.hex
  end

  def get_gas_price
    uri = URI(@rpc_url)
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.body = {
      jsonrpc: "2.0",
      method: "eth_gasPrice",
      params: [],
      id: 1
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    puts "====================="
    puts "Get Gas Price"
    puts "====================="
    puts response.body
    puts "====================="

    result = JSON.parse(response.body)["result"]
    result.hex
  end

  def send_raw_transaction(hex)
    uri = URI(@rpc_url)
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.body = {
      jsonrpc: "2.0",
      method: "eth_sendRawTransaction",
      params: ['0x' + hex],
      id: 1
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    puts "====================="
    puts "Send Raw Tx"
    puts "====================="
    puts response.body
    puts "====================="

    JSON.parse(response.body)["result"]
  end
end
