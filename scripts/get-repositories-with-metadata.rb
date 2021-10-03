#!/usr/bin/env ruby

# Copyright: (C) 2019 iCub Tech Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.
#
# The env variable GITHUB_TOKEN_VVV_SCHOOL shall contain a valid GitHub token
# (refer to instructions to find out more)
#
# script for trasversing GitHub pagination
#

require 'octokit'
require 'json'
require './helpers'

if ARGV.length < 2 then
  puts "Usage: $0 <organization> <request>"
  puts "Example: ./get-repositories-with-metadata.rb vvv-school '{\"maintainer\": [{\"username\":\"pattacini\"}]}'"
  exit 1
end

Signal.trap("INT") {
  exit 2
}

Signal.trap("TERM") {
  exit 2
}

# function copied out from https://gist.github.com/agius/2631752
def different?(a, b)
  return [a.class.name, nil] if !a.nil? && b.nil?
  return [nil, b.class.name] if !b.nil? && a.nil?
  
  differences = {}
  a.each do |k, v|
    if !v.nil? && b[k].nil?
      differences[k] = [v, nil]
      next
    elsif !b[k].nil? && v.nil?
      differences[k] = [nil, b[k]]
      next
    end
      
    if v.is_a?(Hash)
      unless b[k].is_a?(Hash)
        differences[k] = "Different types" 
        next
      end
      diff = different?(a[k], b[k])
      differences[k] = diff if !diff.nil? && diff.count > 0
    elsif v.is_a?(Array)
      unless b[k].is_a?(Array)
        differences[k] = "Different types"
        next
      end
      
      c = 0
      diff = v.map do |n|
        if n.is_a?(Hash)
          diffs = different?(n, b[k][c])
          c += 1
          ["Differences: ", diffs] unless diffs.nil?
        else
          c += 1
          [n , b[c]] unless b[c] == n
        end
      end.compact
      
      differences[k] = diff if diff.count > 0
    else
      differences[k] = [v, b[k]] unless v == b[k]
    end
  end
  
  return differences if !differences.nil? && differences.count > 0
end

def process(client, json_request, repo)
  check_and_wait_until_reset(client)
  begin
    metadata = client.contents(repo.full_name, :path => '.metadata.json')
  rescue
  else
    json_metadata = JSON.parse(Base64.decode64(metadata.content))
    if different?(json_request, json_metadata).nil?
      puts "#{repo.name}"
    end
  end
end

json_request = JSON.parse(ARGV[1])
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
  data.each { |repo| process(client, json_request, repo) }
  if last_response.rels[:next].nil?
    break
  else
    last_response = last_response.rels[:next].get
  end
end
