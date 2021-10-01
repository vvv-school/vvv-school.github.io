# Copyright: (C) 2020 iCub Tech Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>


#########################################################################################
def check_and_wait_until_reset(client)
    rate_limit = client.rate_limit
    if rate_limit.remaining == 0 then
        reset_secs = rate_limit.resets_in
        reset_mins = reset_secs / 60
        puts ""
        puts "⏳ We hit the GitHub API rate limit; reset will occur at #{rate_limit.resets_at} in #{reset_mins} mins"
        puts ""
        reset_secs = reset_secs + 60
        sleep(reset_secs)
    end
end
