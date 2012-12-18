# encoding: utf-8

puts "HealthSeven specs: Running on Ruby Version: #{RUBY_VERSION}"

require "rubygems"
require "bundler"
Bundler.setup

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require "health_seven"
def load_message(name)
  msg = File.read(File.join(File.dirname(__FILE__), 'messages', "#{name}.hl7"))
  msg.gsub!("\n", "\r")
  "#{msg}\n"
end
