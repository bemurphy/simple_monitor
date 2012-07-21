require "simple_monitor/version"

module SimpleMonitor
  attr_reader :options
  attr_accessor :logger

  # Sets if logging should only occur when
  # you call it, skips implementation logging
  attr_accessor :only_explicit_logging

  LOG_METHODS = %w[info warn error debug].freeze

  def initialize(options = {})
    self.only_explicit_logging = options.delete(:only_explicit_logging)
    @options = options
  end

  # Runs the check and sends an alert if needed
  #
  # Returns false if the check failed, true if passed
  def check
    if needs_alert?
      warn_alert
      send_alert
      false
    else
      info_passed
      true
    end
  end

  def warn_alert
    unless only_explicit_logging
      warn(alert_log_message)
    end
  end

  # Public: Message to log in case of an alert
  #
  # Override this in your monitors to inject data
  #
  # Returns: String
  def alert_log_message
    "check generated an alert"
  end

  def info_passed
    unless only_explicit_logging
      info(passed_log_message)
    end
  end

  # Public: Message to log in case of a check passing
  #
  # Override this in your monitors to inject data
  #
  # Returns: String
  def passed_log_message
    "check passed"
  end

  # Public: Conditional method to check if the alert should be sent
  #
  # This should be overridden in your individual monitor classes
  #
  # Returns a boolean
  def needs_alert?
    false
  end

  # Public: Send out an alert
  #
  # This should be overridden in your individual monitor classes,
  # or base monitor class.  This might be to send an SMS, email
  # or IRC message
  def send_alert
    #no-op
  end

  # A memoized logger.
  #
  # Returns: a logger that responds to warn, info, debug, and error
  def logger
    @logger ||=
      if defined?(Rails)
        Rails.logger
      else
        require "logger"
        Logger.new(STDOUT)
      end
  end

  # Generated methods delegated to the logger.  This is for convenience
  # as well as for prefixing the monitor class name into the message
  LOG_METHODS.each do |method|
    define_method method do |message|
      message = [self.class.name, message.to_s].join(" -- ")
      logger.send(method, message)
    end
  end
end
