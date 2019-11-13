#!/usr/bin/env ruby

# Copyright: (C) 2019 iCub Facility - Istituto Italiano di Tecnologia
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

if ARGV.length < 2 then
  puts "Usage: $0 <org> <tag>"
  exit 1
end

Signal.trap("INT") {
  exit 2
}

Signal.trap("TERM") {
  exit 2
}

org = ARGV[0]
tag = ARGV[1]

client = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN_VVV_SCHOOL']
loop do
  client.org_repos(org,{:type => 'all'})
  rate_limit = client.rate_limit
  if rate_limit.remaining > 0 then
    break
  end
  sleep(60)
end

repos = []

last_response = client.last_response
data=last_response.data
data.each { |x| repos << x.full_name }

until last_response.rels[:next].nil?
  last_response = last_response.rels[:next].get
  data=last_response.data
  data.each { |x| repos << x.full_name }
end

repos.each { |repo|
  ref="tags/"+tag
  begin
    client.delete_ref(repo,ref)
    puts "#{repo}: #{ref} deleted"
  rescue
    puts "#{repo}: #{ref} not found"
  end
}




