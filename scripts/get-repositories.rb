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
  puts "Usage: $0 <organization>"
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
  client.org_repos(ARGV[0],{:type => 'all'})
  rate_limit = client.rate_limit
  if rate_limit.remaining > 0 then
    break
  end
  sleep(60)
end

last_response = client.last_response
data=last_response.data
data.each { |x| puts "#{x.name}" }

until last_response.rels[:next].nil?
  last_response = last_response.rels[:next].get
  data=last_response.data
  data.each { |x| puts "#{x.name}" }
end


