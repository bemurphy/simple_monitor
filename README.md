SimpleMonitor
=============

Send alerts based on simple monitored conditions in your app.

It provides a basic skeleton for writing unique but consistent
monitoring checks for your application.  Examples of such checks
are a Delayed::Job queue that is too full, too many failed logins
in the last 5 minutes, or a remote service being unreachable.

Installation
------------

install it via rubygems:

```
gem install simple_monitor
```

or put it in your Gemfile:

```ruby
# Gemfile
gem 'simple_monitor'
```

Usage
-----

SimpleMonitor should be mixed in to a SomeConditionMonitor class

```ruby
require "simple_monitor"

class HighJobMonitor
  include SimpleMonitor

  # This is the most important method you should override
  # It returns true/false to determine if there's an alert
  def needs_alert?
    Queue.jobs.count > options[:job_count_threshold]
  end

  # Alert sending method of your choice.  SimpleMonitor
  # leaves this up to you
  def send_alert
    Mailer.deliver_high_job_alert(Queue.jobs.count)
  end
end

monitor = HighJobMonitor.new(:job_count_threshold => 99)
monitor.check
```

For a typical application, it could be desirable to define an
AppMonitor class with a default send_alert method, and have your
individual monitor classes inherit from that.

A monitor class can take options on initialization; this is recommended
for passing in thresholds, email addresses, or other dependencies.

Logging
-------

SimpleMonitor defaults its logger to a new Logger instance, or
Rails.logger if that is defined.  If you want to override this,
do so in your class or via the `logger=` instance method.

When running a `check`, the logger will be warned or provided
with info whether an alert was needed.  Note this is in addition
to sending out an alert.

#### Copyright

Copyright (c) (2012) Brendon Murphy. See license.txt for details.

