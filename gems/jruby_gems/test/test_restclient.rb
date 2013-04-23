require "rubygems"
require 'bundler/setup'
require 'rest-client'

p RestClient.get 'http://www.baidu.com'
