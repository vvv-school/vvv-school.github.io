#!/usr/bin/env ruby

require 'octokit'

if ARGV.length < 1 then
  puts "Usage: $0 <team-id>"
  exit 1
end

client = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN_ORG_READ']
client.team_members(ARGV[0])

last_response = client.last_response
data=last_response.data
data.each { |x| puts "#{x.login}" }

until last_response.rels[:next].nil?
  last_response = last_response.rels[:next].get
  data=last_response.data
  data.each { |x| puts "#{x.login}" }
end

