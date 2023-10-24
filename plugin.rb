# frozen_string_literal: true

# name: discourse-6dc-tipper
# about: A discourse plugin to enable users to sign-in through Ethereum networks and tip users
# url: https://github.com/6doworld/discourse-6dc-tipper
# version: 0.1.0

enabled_site_setting :discourse_6dc_tipper
register_svg_icon 'fab-ethereum'
register_asset 'stylesheets/discourse-6dc-tipper.scss'
register_svg_icon "hand-holding-usd" # 6DC Plugin Tipper addition

# Site setting validators must be loaded before initialize
%w[
  ../lib/omniauth/strategies/siwe.rb
  ../lib/validators/tipper_value_validator.rb
].each { |path| load File.expand_path(path, __FILE__) }

gem 'pkg-config', '1.5.1', require: false
gem 'mkmfmf', '0.4', require: false
gem 'keccak', '1.3.0', require: false
gem 'zip', '2.0.2', require: false
gem 'mini_portile2', '2.8.0', require: false
gem 'rbsecp256k1', '5.1.1', require: false
gem 'konstructor', '1.0.2', require: false
gem 'ffi', '>=1.16.3', require: false
gem 'ffi-compiler', '1.0.1', require: false
gem 'scrypt', '3.0.7', require: false
gem 'eth', '0.5.6', require: false
gem 'siwe', '1.1.2', require: false

class ::Discourse6dcAuthenticator < ::Auth::ManagedAuthenticator
  def name
    'siwe'
  end

  def register_middleware(omniauth)
    omniauth.provider :siwe,
                      setup: lambda { |env|
                        strategy = env['omniauth.strategy']
                      }
  end

  def enabled?
    SiteSetting.discourse_6dc_tipper
  end

  def primary_email_verified?
    false
  end
end

auth_provider authenticator: ::Discourse6dcAuthenticator.new,
              icon: 'fab-ethereum',
              full_screen_login: true

after_initialize do
  %w[
    ../lib/discourse_6dc_tipper/engine.rb
    ../lib/discourse_6dc_tipper/routes.rb
    ../app/models/wallet_transactions.rb
    ../app/controllers/auth_controller.rb
    ../app/controllers/transaction_controller.rb
  ].each { |path| load File.expand_path(path, __FILE__) }

  Discourse::Application.routes.prepend do
    mount ::Discourse6dcTipper::Engine, at: '/discourse-6dc-tipper'
  end
end
