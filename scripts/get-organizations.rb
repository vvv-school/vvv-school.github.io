#!/usr/bin/env ruby

require 'octokit'

if ARGV.length < 2 then
  puts "Usage: $0 <organization> <output-file>"
  exit 1
end

client = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN_ORG_READ']

results = client.org_repos(ARGV[0],{:type => 'public'})
last_response = client.last_response
number_of_pages = last_response.rels[:last].href.match(/page=(\d+).*$/)[1]
puts "number of pages = #{number_of_pages}"

out_file = File.new(ARGV[1],"w")
data=last_response.data
data.each { |x| out_file.puts("#{x.name}") }

until last_response.rels[:next].nil?
  last_response = last_response.rels[:next].get
  data=last_response.data
  data.each { |x| out_file.puts("#{x.name}") }
end

out_file.close

