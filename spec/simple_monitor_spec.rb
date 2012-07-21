require 'spec_helper'

class TestMonitor < SimpleMonitor
  attr_reader :last_alert

  def needs_alert?
    options[:force_alert]
  end

  def send_alert
    @last_alert = "Test Monitor Alert"
  end
end

describe SimpleMonitor do
  it "is initilized with optional options" do
    monitor = SimpleMonitor.new
    monitor = SimpleMonitor.new(:foo => :bar)
    monitor.options[:foo].should == :bar
  end
end

describe SimpleMonitor, "logger" do
  let(:subject) { TestMonitor.new}

  it "is defaulted to Logger.new(STDOUT)" do
    subject.logger.should be_kind_of(Logger)
  end

  # Problem, what if its vendored and rails and run in a spec run
  # that boots rails?
  it "is defaulted to the Rails.logger if present" do
    module Rails
      def self.logger
        :rails_logger
      end
    end

    subject.logger.should == :rails_logger

    Object.send(:remove_const, :Rails)
  end

  it "is configurable by setting the class logger_factory to a callable" do
    SimpleMonitor.logger_factory = Proc.new { :factory_override }
    subject.logger.should == :factory_override
    SimpleMonitor.reset_logger_factory
  end

  it "sends info, warn, error, and debug methods to it prefixed by the class name" do
    stub_logger = stub('logger')
    SimpleMonitor.logger_factory = Proc.new { stub_logger }
    %w[info warn error debug].each do |log_method|
      stub_logger.should_receive(log_method).with("TestMonitor -- #{log_method}")
      subject.send(log_method, log_method)
    end
  end
end

describe SimpleMonitor, "running the check" do
  let(:subject) { TestMonitor.new }
  let(:logger) { stub('logger', :warn => nil, :info => nil) }
  before { SimpleMonitor.logger_factory = Proc.new { logger } }
  after { SimpleMonitor.reset_logger_factory }

  context "when an alert needs sending" do
    before { subject.options[:force_alert] = true }

    it "logs a warning that the check is in alert" do
      logger.should_receive(:warn).with(/TestMonitor --.*alert/)
      subject.check
    end

    it "sends an alert" do
      subject.check
      subject.last_alert.should == "Test Monitor Alert"
    end
  end

  context "when no alert needs sending" do
    before { subject.options[:force_alert] = false }

    it "logs info that the check passed" do
      logger.should_receive(:info).with(/TestMonitor --.*passed/)
      subject.check
    end

    it "doesn't send an alert" do
      subject.check
      subject.last_alert.should be_nil
    end
  end
end
