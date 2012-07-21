require "simple_monitor/version"

module SimpleMonitor
  attr_reader :options
  attr_accessor :logger

  LOG_METHODS = %w[info warn error debug].freeze

  def initialize(options = {})
    @options = options
  end

  def check
    if needs_alert?
      warn_alert
      send_alert
    else
      info_passed
    end
  end

  def warn_alert
    warn(alert_log_message)
  end

  def alert_log_message
    "check generated an alert"
  end

  def info_passed
    info(passed_log_message)
  end

  def passed_log_message
    "check passed"
  end

  def needs_alert?
    false
  end

  def send_alert
    #no-op
  end

  def logger
    @logger ||=
      if defined?(Rails)
        Rails.logger
      else
        require "logger"
        Logger.new(STDOUT)
      end
  end

  LOG_METHODS.each do |method|
    define_method method do |message|
      message = [self.class.name, message.to_s].join(" -- ")
      logger.send(method, message)
    end
  end
end
