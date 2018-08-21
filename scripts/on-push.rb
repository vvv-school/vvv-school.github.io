#!/usr/bin/env ruby

# Copyright: (C) 2018 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.
#
# Dependencies (through gem):
# - sinatra
# - json

webhook_file_name = "/tmp/github-webhook-vvv-school"
webhook_file = open(webhook_file_name,"w+")

at_exit {
  puts "cleaning up..."
  webhook_file.close
  File.delete(webhook_file_name)
}

require 'sinatra'
require 'json'

set :bind, '0.0.0.0'
if ARGV.length > 0 then
  set :port, ARGV[0]
end

puts "starting..."
webhook_requests = 0

post '/payload' do
  payload = JSON.parse(request.body.read)
  if payload.key?("repository") then
    repository = payload["repository"]["full_name"].downcase
    if repository.include?("assignment") or repository.include?("tutorial") then
      puts "Detected activity on #{repository}"
      webhook_requests = webhook_requests + 1
      webhook_file.puts webhook_requests
      webhook_file.flush
    end  
  end
  "Request served!\n"
end

get '/' do
  "Hi there!\n"
end
