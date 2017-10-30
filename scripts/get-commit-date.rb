#!/usr/bin/env ruby

# Copyright: (C) 2016 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.
#
# Dependencies (through gem):
# - octokit
#
# The env variable GITHUB_TOKEN_VVV_SCHOOL shall contain a valid GitHub token
# (refer to instructions to find out more)
#
# script for trasversing GitHub pagination
#

require 'octokit'

if ARGV.length < 1 then
  puts "Usage: $0 <repository>"
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
  client.commits(ARGV[0])
  rate_limit = client.rate_limit
  if rate_limit.remaining > 0 then
    break
  end
  sleep(60)
end

last_response = client.last_response
data=last_response.data
puts "#{data[0].commit.committer.date}"


