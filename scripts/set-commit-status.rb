#!/usr/bin/env ruby

# Copyright: (C) 2017 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.
#
# Dependencies (through gem):
# - octokit
#
# The env variable GITHUB_TOKEN_ORG_READ should contain a valid GitHub
# token with "org:read" permission to retrieve organization data
#
# script for trasversing GitHub pagination
#

require 'octokit'

if ARGV.length < 2 then
  puts "Usage: $0 <repository> <status> [<target_url>]"
  puts ""
  puts "<status> can be pending,success,failure,error"
  exit 1
end

repo=ARGV[0]
status=ARGV[1]

if (status != "pending") && (status != "success") &&
   (status != "failure") && (status != "error") then
    puts "unknown status specified"
  exit 1
end

Signal.trap("INT") {
  exit 2
}

Signal.trap("TERM") {
  exit 2
}

client = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN_ORG_READ']
loop do
  client.commits(repo)
  rate_limit = client.rate_limit
  if rate_limit.remaining > 0 then
    break
  end
  sleep(60)
end

last_response = client.last_response
sha=last_response.data[0].sha

context="Robot Testing Framework"
if status == "pending" then
  description="Your solution is being verified"
elsif status == "success" then
  description="Your solution passed"
elsif status == "failure" then
  description="Your solution failed"
elsif status == "error" then
  description="Cannot build/check your solution"
end

if ARGV.length < 3 then  
  client.create_status(repo,sha,status,
                       :context => context,
                       :description => description)
else
  client.create_status(repo,sha,status,
                       :context => context,
                       :description => description,
                       :target_url => ARGV[2])
end                       
