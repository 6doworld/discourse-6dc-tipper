# frozen_string_literal: true

require 'redis'

module Jobs
  module Discourse6dcTipper
    class TransferService < ::Jobs::Scheduled
      every 1.minutes
      # every 5.seconds

      @@redis = Redis.new # Instantiate Redis connection once

      def execute(args = {})
        # return if !SiteSetting.chat_enabled
        Rails.logger.info("[6DOTipper] Call - Transfer Service Job")

        pid = @@redis.get("service_pid") # Get the PID from Redis

        if pid.nil? || !process_running?(pid)
          path = "#{File.dirname(__FILE__)}/6dc-service-linux"
          Rails.logger.info("[6DOTipper] Service Path : #{path}")

          pid = spawn(path)
          Process.detach(pid)
          @@redis.set("service_pid", pid) # Store the PID in Redis

          Rails.logger.info("[6DOTipper] Running Transfer Service")
        end
      end

      def process_running?(pid)
        Process.getpgid(pid.to_i) != -1
      rescue Errno::ESRCH
        false
      end
    end
  end
end