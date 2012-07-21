require 'spec_helper'

class TestMonitor
  include SimpleMonitor

  attr_reader :last_alert

  def needs_alert?
    options[:force_alert]
  end

  def send_alert
    @last_alert = "Test Monitor Alert"
  end
end

describe SimpleMonitor do
  it "is initialized with optional options" do
    monitor = TestMonitor.new
    monitor = TestMonitor.new(:foo => :bar)
    monitor.options[:foo].should == :bar
  end

  it "extracts :only_explicit_logging from the passed options" do
    TestMonitor.new.only_explicit_logging.should be_nil
    TestMonitor.new(:only_explicit_logging => true).only_explicit_logging.should be_true
  end
end

describe SimpleMonitor, "logger" do
  subject { TestMonitor.new }

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

  it "sends info, warn, error, and debug methods to it prefixed by the class name" do
    stub_logger = stub('logger')
    subject.logger = stub_logger
    %w[info warn error debug].each do |log_method|
      stub_logger.should_receive(log_method).with("TestMonitor -- #{log_method}")
      subject.send(log_method, log_method)
    end
  end
end

describe SimpleMonitor, "running the check" do
  subject { TestMonitor.new }
  let(:logger) { stub('logger', :warn => nil, :info => nil) }
  before { subject.logger = logger }

  context "when an alert needs sending" do
    before { subject.options[:force_alert] = true }

    it "logs a warning that the check is in alert" do
      logger.should_receive(:warn).with(/TestMonitor --.*alert/)
      subject.check
    end

    it "can bypass the logging if only_explicit_logging is set" do
      subject.only_explicit_logging = true
      logger.should_not_receive(:warn)
      subject.check
    end

    it "sends an alert" do
      subject.check
      subject.last_alert.should == "Test Monitor Alert"
    end

    it "returns false" do
      subject.check.should == false
    end
  end

  context "when no alert needs sending" do
    before { subject.options[:force_alert] = false }

    it "logs info that the check passed" do
      logger.should_receive(:info).with(/TestMonitor --.*passed/)
      subject.check
    end

    it "can bypass the logging if only_explicit_logging is set" do
      subject.only_explicit_logging = true
      logger.should_not_receive(:info)
      subject.check
    end

    it "doesn't send an alert" do
      subject.check
      subject.last_alert.should be_nil
    end

    it "returns true" do
      subject.check.should == true
    end
  end
end

describe SimpleMonitor, "supports a class including SimpleMonitor" do
  class ChildTestMonitor < TestMonitor
    def needs_alert?
      true
    end

    def send_alert
      @last_alert = "CHILD HERE"
    end
  end

  subject { ChildTestMonitor.new }
  let(:logger) { stub('logger', :warn => nil, :info => nil) }
  before { subject.logger = logger }

  it "to be inherited" do
    subject.check
    subject.last_alert.should == "CHILD HERE"
  end
end
