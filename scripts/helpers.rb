#########################################################################################
def check_and_wait_until_reset(client)
    rate_limit = client.rate_limit
    if rate_limit.remaining == 0 then
        reset_secs = rate_limit.resets_in
        reset_mins = reset_secs / 60
        puts "⏳ We hit the GitHub API rate limit; reset will occur at #{rate_limit.resets_at} in #{reset_mins} mins"
        reset_secs = reset_secs + 60
        wait(reset_secs)
    end
end
