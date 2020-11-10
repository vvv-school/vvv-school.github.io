#!/usr/bin/env ruby

# Copyright: (C) 2019 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.
#
# The env variable GITHUB_TOKEN_VVV_SCHOOL shall contain a valid GitHub token
# (refer to instructions to find out more)
#
# script for trasversing GitHub pagination
#

require 'octokit'

if ARGV.length < 6 then
  puts "Usage: $0 <org> <tag> <message> <tagger_name> <tagger_email> <date>"
  puts "<date> is formatted as yyyy-mm-dd"
  exit 1
end

Signal.trap("INT") {
  exit 2
}

Signal.trap("TERM") {
  exit 2
}

org          = ARGV[0]
tag          = ARGV[1]
message      = ARGV[2]
tagger_name  = ARGV[3]
tagger_email = ARGV[4]
date         = ARGV[5]

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
data = last_response.data
data.each { |x| repos << x.name }

until last_response.rels[:next].nil?
  last_response = last_response.rels[:next].get
  data = last_response.data
  data.each { |x| repos << x.name }
end

repos.each { |repo|
  repo_full=org+"/"+repo
  if repo.start_with?("tutorial_","assignment_","solution_") ||
     repo.casecmp?(org+".github.io")
    client.commits_before(repo_full,date)
    last_response = client.last_response
    data = last_response.data
    if data.any?
      commit = data[0].sha
      tagger_date = Time.now.strftime("%Y-%m-%dT%H:%M:%S%:z")
      begin
        client.create_tag(repo_full,tag,message,commit,"commit",tagger_name,tagger_email,tagger_date)
        ref = client.last_response.data.sha
        client.create_ref(repo_full,"refs/tags/"+tag,ref)
        puts "#{repo_full}@#{commit}: tagged as #{tag}"
      rescue
        puts "#{repo_full}@#{commit}: remained untagged --> #{tag} already exists"
      end  
    else
      puts "#{repo_full}: no corresponding commit found"
    end
  else
    puts "#{repo_full}: skipped"
  end
}




