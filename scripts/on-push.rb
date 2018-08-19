#!/usr/bin/env ruby

# Copyright: (C) 2018 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.
#
# Dependencies (through gem):
# - sinatra
# - json

at_exit {
  puts "cleaning up..."
  ENV['GITHUB_WEBHOOK_VVV_SCHOOL'] = nil
}

require 'sinatra'
require 'json'

if ARGV.length > 0 then
  set :port, ARGV[0]
end

puts "starting..."
ENV['GITHUB_WEBHOOK_VVV_SCHOOL'] = "0"

post '/payload' do
  push = JSON.parse(request.body.read)
  repository = push["repository"]["full_name"]
  puts "Detected activity on #{repository}"
  ENV['GITHUB_WEBHOOK_VVV_SCHOOL'] = (ENV['GITHUB_WEBHOOK_VVV_SCHOOL'].to_i + 1).to_s
end

