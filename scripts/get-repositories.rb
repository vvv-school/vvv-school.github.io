#!/usr/bin/env ruby

# Copyright: (C) 2016 iCub Facility - Istituto Italiano di Tecnologia
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
  check_and_wait_until_reset(client)
  begin
    client.org_repos(ARGV[0],{:type => 'all'})
  rescue
  else
    break
  end
end

last_response = client.last_response
loop do
  data = last_response.data
  data.each { |repo| puts "#{repo.name}" }
  if last_response.rels[:next].nil?
    break
  else
    last_response = last_response.rels[:next].get
  end
end
