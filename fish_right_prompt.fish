# Colors vary depending on time lapsed.
set -g FISH_GIT_TIME_SINCE_COMMIT_SHORT (set_color -o green)
set -g FISH_GIT_TIME_SHORT_COMMIT_MEDIUM (set_color -o yellow)
set -g FISH_GIT_TIME_SINCE_COMMIT_LONG (set_color CC0000)
set -g FISH_GIT_TIME_SINCE_COMMIT_NEUTRAL (set_color -o cyan)
set -g normal (set_color normal)

function _git_time_since_commit
    if [ (command git rev-parse --git-dir ^/dev/null) ]
        # Only proceed if there is actually a commit.
        if [ (command git log 2>&1 > /dev/null | grep -c "^fatal:") -eq 0 ]
            # Get the last commit.
            set last_commit (command git log --pretty=format:'%at' -1 2> /dev/null)
            set now (command date +%s)
            set seconds_since_last_commit (math "$now-$last_commit")

            # Totals
            set MINUTES (math "$seconds_since_last_commit / 60")
            set HOURS (math "$seconds_since_last_commit/3600")

            # Sub-hours and sub-minutes
            set DAYS (math "$seconds_since_last_commit / 86400")
            set SUB_HOURS (math "$HOURS % 24")
            set SUB_MINUTES (math "$MINUTES % 60")

            if git status -s > /dev/null
                if [ "$MINUTES" -gt 30 ]
                    set COLOR $FISH_GIT_TIME_SINCE_COMMIT_LONG
                else if [ "$MINUTES" -gt 10 ]
                    set COLOR $FISH_GIT_TIME_SHORT_COMMIT_MEDIUM
                else
                    set COLOR $FISH_GIT_TIME_SINCE_COMMIT_SHORT
                end
            else
                set COLOR $ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL
            end

            if [ "$HOURS" -gt 24 ]
                echo "[$COLOR$DAYS""d""$SUB_HOURS""h""$SUB_MINUTES""m""$normal]"
            else if [ "$MINUTES" -gt 60 ]
                echo "[$COLOR$HOURS""h""$SUB_MINUTES""m""$normal]"
            else
                echo "[$COLOR$MINUTES""m""$normal]"
            end
        else
            set COLOR $FISH_GIT_TIME_SINCE_COMMIT_NEUTRAL
            echo "[$COLOR~$normal]"
        end
    end
end

function fish_right_prompt
    set -l git_status (_git_time_since_commit)
    echo -n -s $git_status
end
