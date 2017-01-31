#!/usr/bin/env ruby

# Copyright: (C) 2016 iCub Facility - Istituto Italiano di Tecnologia
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
  puts "Usage: $0 <organization> <team>"
  exit 1
end

client = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN_ORG_READ']
loop do
  client.org_teams(ARGV[0])
  rate_limit = client.rate_limit
  if rate_limit.remaining > 0 then
    break
  end
  sleep(60)
end

last_response = client.last_response
data=last_response.data

team_id = -1
data.each { |x|
if x.name == ARGV[1] then
  team_id = x.id
end
}

if team_id < 0 then
  until last_response.rels[:next].nil?
    last_response = last_response.rels[:next].get
    data=last_response.data
    data.each { |x|
    if x.name == ARGV[1] then
      team_id = x.id
      break
    end
    }
  end
end

if team_id >= 0 then
  loop do
    client.team_members(team_id)
    rate_limit = client.rate_limit
    if rate_limit.remaining > 0 then
      break
    end
    sleep(60)
  end

  last_response = client.last_response
  data=last_response.data
  data.each { |x| puts "#{x.login}" }

  until last_response.rels[:next].nil?
    last_response = last_response.rels[:next].get
    data=last_response.data
    data.each { |x| puts "#{x.login}" }
  end
end

