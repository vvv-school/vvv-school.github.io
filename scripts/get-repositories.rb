#!/usr/bin/env ruby

require 'octokit'

if ARGV.length < 1 then
  puts "Usage: $0 <organization>"
  exit 1
end

client = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN_ORG_READ']
client.org_repos(ARGV[0],{:type => 'public'})

last_response = client.last_response
data=last_response.data
data.each { |x| puts "#{x.name}" }

until last_response.rels[:next].nil?
  last_response = last_response.rels[:next].get
  data=last_response.data
  data.each { |x| puts "#{x.name}" }
end


