# https://blog.appsignal.com/2019/03/05/stringscanner.html?utm_source=RubyMagic&utm_medium=email&utm_campaign=20190305_Stringscanner
require 'strscan'

class ScannerLogger
  attr_accessor :log_entry
  attr_accessor :log
  attr_reader :scanner

  def initialize(log_entry = nil)
    @log = {}
    @log_entry = log_entry || <<-EOS
Started GET "/" for 127.0.0.1 at 2017-08-20 20:53:10 +0900
Processing by HomeController#index as HTML
  Rendered text template within layouts/application (0.0ms)
  Rendered layouts/_assets.html.erb (2.0ms)
  Rendered layouts/_top.html.erb (2.6ms)
  Rendered layouts/_about.html.erb (0.3ms)
  Rendered layouts/_google_analytics.html.erb (0.4ms)
Completed 200 OK in 79ms (Views: 78.8ms | ActiveRecord: 0.0ms)
EOS
  end

  def saninitized_logger
    @scanner = StringScanner.new(@log_entry)

    log[:method] = get_method
    log[:path] = get_path
    log[:ip] = get_ip
    log[:timestamp] = get_timestamp
    log[:success] = get_success
    log[:response_code] = get_response_code
    log[:duration] = get_duration
    log
  end

  def get_method
    @scanner.skip(/Started /)
    @scanner.scan_until(/[A-Z]+/)
  end

  def get_path
    @scanner.scan(/\s"(.+)"/)
    @scanner.captures.first
  end

  def get_ip
    @scanner.skip(/ for /)
    @scanner.scan_until(/[^\s]+/)
  end

  def get_timestamp
    @scanner.skip(/ at /)
    @scanner.scan_until(/$/)
  end

  def get_success
    @scanner.skip_until(/Completed /)
    @scanner.peek(1) == "2"
  end

  def get_response_code
    @scanner.scan(/\d{3}/)
  end

  def get_duration
    @scanner.skip(/ OK in /)
    @scanner.scan_until(/ms/)
  end
end

custom_log = <<-EOS
Started GET "/" for 127.0.0.1 at 2017-08-20 20:53:10 +0900
Processing by HomeController#index as HTML
  Rendered text template within layouts/application (0.0ms)
  Rendered layouts/_assets.html.erb (2.0ms)
  Rendered layouts/_top.html.erb (2.6ms)
  Rendered layouts/_about.html.erb (0.3ms)
  Rendered layouts/_google_analytics.html.erb (0.4ms)
Completed 200 OK in 79ms (Views: 78.8ms | ActiveRecord: 0.0ms)
EOS

scanner_logger = ScannerLogger.new(custom_log)
puts scanner_logger.saninitized_logger
