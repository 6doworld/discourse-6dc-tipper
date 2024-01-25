require 'eth'
require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require 'base64'

class EthereumTransaction
  def initialize(private_key, wallet_address, rpc_url, chain_id = 1, contract_address = '')
    @private_key_plain = private_key
    @wallet_address = wallet_address
    @rpc_url = rpc_url
    @chain_id = chain_id
    @contract_address = contract_address
  end

  def decrypt_key(encrypted_data, key = 'DDNrUYO0tGayTPOXUFt6/z6Wm78ZaHlRvFcBPyxXfV0=', iv = '4+fEe1ZMwKi3jWUtOHoBtQ==')
    puts "[DISCOURSE-6DC-TIPPER-TRANSACTION] #{encrypted_data} | #{key} | #{iv}"

    decipher = OpenSSL::Cipher.new('AES-256-CBC')
    decipher.decrypt
    decipher.key = Base64.decode64(key)
    decipher.iv = Base64.decode64(iv)

    # Decrypt the data
    decrypted_data = decipher.update(Base64.decode64(encrypted_data)) + decipher.final

    return decrypted_data
  end

  def send_transaction(to, ether_value)
    uri = URI("http://localhost:4738/transfer")
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  
    puts "[DISCOURSE-6DC-TIPPER-TRANSACTION] p1"

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
            handlerAddress: ENV['DISCOURSE_6DC_PLATFORM_WALLET'] || '0x3D390AF6f9CE449A75403Ad51Bdf29965a1Db9dB',
            handlerPrivateKey: decrypt_key(ENV['DISCOURSE_6DC_PLATFORM_WALLET_PK'] || 'x/kS6PHVDB8NML0Bfx5F/MF15mBk6Phoy5fhlZ1gIBsHsomEbOYkQSgO9sBCVnY1jrQLXl1un+pfgxSHTbJp5p5yv7PprOmTdlk2EJVuDiU='),
            amount: ether_value
          }
        }.to_json

        puts request.body
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

      puts "[DISCOURSE-6DC-TIPPER-TRANSACTION] p2"

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
