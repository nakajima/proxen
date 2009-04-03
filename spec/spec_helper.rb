require 'rubygems'
require 'spec'
require 'rr'

require File.dirname(__FILE__) + '/../lib/proxen'

Spec::Runner.configure { |c| c.mock_with(:rr) }