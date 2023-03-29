# frozen_string_literal: true

module ::Discourse6dcTipper
  PLUGIN_NAME ||= 'discourse-6dc-tipper'
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace Discourse6dcTipper
  end
end
