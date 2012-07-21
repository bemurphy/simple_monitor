require "simple_monitor/version"
require "logger"

class SimpleMonitor
  attr_reader :options

  class << self
    def logger_factory
      @@logger_factory ||= Proc.new {
        if defined?(Rails)
          Rails.logger
        else
          Logger.new(STDOUT)
        end
      }
    end

    def logger_factory=(callable)
      @@logger_factory = callable
    end

    def reset_logger_factory
      @@logger_factory = nil
    end
  end

  def initialize(options = {})
    @options = options
  end

  def check
    if needs_alert?
      warn(alert_log_message)
      send_alert
    else
      info(passed_log_message)
    end
  end

  def alert_log_message
    "check generated an alert"
  end

  def passed_log_message
    "check passed"
  end

  def needs_alert?
    false
  end

  def logger
    @logger ||= SimpleMonitor.logger_factory.call
  end

  %w[info warn error debug].each do |method|
    define_method method do |message|
      message = [self.class.name, message.to_s].join(" -- ")
      logger.send(method, message)
    end
  end
end
