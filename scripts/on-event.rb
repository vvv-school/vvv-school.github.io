#!/usr/bin/env ruby

# Copyright: (C) 2018 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.
#

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
  ok = false
  payload = JSON.parse(request.body.read)
  repo = payload["repository"]
  if repo then
    repo = repo["full_name"]
    if repo then
      repo = repo.downcase
      if repo.include?("assignment") or repo.include?("tutorial") then
        puts "Detected activity on #{repo}"
        webhook_requests = webhook_requests + 1
        webhook_file.puts webhook_requests
        webhook_file.flush
        ok = true
      end
    end
  end
  status 200
  if ok then
    "Request served correctly!\n"
  else
    "Nothing to do with this request!\n"
  end
end

get '/' do
  status 200
  "Greetings!\n"
end
