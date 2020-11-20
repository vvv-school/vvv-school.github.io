#!/usr/bin/env ruby

# Copyright: (C) 2017 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.
#
# The env variable GITHUB_TOKEN_VVV_SCHOOL shall contain a valid GitHub token
# (refer to instructions to find out more)
#
# script for trasversing GitHub pagination
#

require 'octokit'
require './helpers'

if ARGV.length < 2 then
  puts "Usage: $0 <repository> <status> [<target_url>] [<success_score>]"
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

client = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN_VVV_SCHOOL']
loop do
  check_and_wait_until_reset(client)
  client.commits(repo)
  rate_limit = client.rate_limit
  if rate_limit.remaining > 0 then
    break
  end
end

last_response = client.last_response
sha = last_response.data[0].sha

context = "Robot Testing Framework"
if status == "pending" then
  description="Your solution is being checked"
elsif status == "success" then
  description="Your solution passed the test"
elsif status == "failure" then
  description="Your solution failed the test"
elsif status == "error" then
  description = "Could not build/check your solution"
end

target_url = ""
if ARGV.length > 2 then
  target_url=ARGV[2]
end
  
if (status == "success") and (ARGV.length > 3) then
  description << " with score " << ARGV[3].to_s
end

check_and_wait_until_reset(client)
client.create_status(repo,sha,status,
                     :context => context,
                     :description => description,
                     :target_url => target_url)
