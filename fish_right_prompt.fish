# Colors vary depending on time lapsed.
set -g FISH_GIT_TIME_SINCE_COMMIT_SHORT (set_color -o green)
set -g FISH_GIT_TIME_SHORT_COMMIT_MEDIUM (set_color -o yellow)
set -g FISH_GIT_TIME_SINCE_COMMIT_LONG (set_color CC0000)
set -g FISH_GIT_TIME_SINCE_COMMIT_NEUTRAL (set_color -o cyan)
set -g normal (set_color normal)

set -g cyan (set_color 33FFFF)
set -g yellow (set_color -o yellow)
set -g red (set_color CC0000)
set -g green (set_color -o green)
set -g white (set_color -o white)
set -g blue (set_color -o blue)
set -g magenta (set_color -o magenta)
set -g normal (set_color normal)
set -g purple (set_color -o purple)

set -g FISH_GIT_PROMPT_ADDED "$green✚$normal"
set -g FISH_GIT_PROMPT_MODIFIED "$blue""M""$normal"
set -g FISH_GIT_PROMPT_DELETED "$red✖$normal"
set -g FISH_GIT_PROMPT_RENAMED "$magenta➜$normal"
set -g FISH_GIT_PROMPT_UNMERGED "$yellow═$normal"
set -g FISH_GIT_PROMPT_UNTRACKED "$cyan✭$normal"
set -g FISH_GIT_PROMPT_CLEAN "$green✔$normal"

function _git_status -d "git repo status about Untracked, new file and so on."
    if [ (command git rev-parse --git-dir 2> /dev/null) ]
        if [ (command git status | grep -c "working directory clean") -eq 1 ]
            echo "$FISH_GIT_PROMPT_CLEAN"
        else
            if [ (command git status | grep -c "Untracked files:") -ne 0 ]
                set output $FISH_GIT_PROMPT_UNTRACKED
            end
            if [ (command git status | grep -c "new file:") -ne 0 ]
                set output "$output $FISH_GIT_PROMPT_ADDED"
            end
            if [ (command git status | grep -c "renamed:") -ne 0 ]
                set output "$output $FISH_GIT_PROMPT_RENAMED"
            end
            if [ (command git status | grep -c "modified:") -ne 0 ]
                set output "$output $FISH_GIT_PROMPT_MODIFIED"
            end
            if [ (command git status | grep -c "deleted:") -ne 0 ]
                set output "$output $FISH_GIT_PROMPT_DELETED"
            end
            echo $output
        end
    end
end


function _git_time_since_commit -d "Display the time since last commit"
    if [ (command git rev-parse --git-dir 2> /dev/null) ]
        # Only proceed if there is actually a commit.
        if [ (command git log 2>&1 > /dev/null | grep -c "^fatal:") -eq 0 ]
            # Get the last commit.
            set last_commit (command git log --pretty=format:'%at' -1 2> /dev/null)
            set now (command date +%s)
            set seconds_since_last_commit (math -s0 "$now-$last_commit")

            # Totals
            set MINUTES (math -s0 "$seconds_since_last_commit / 60")
            set HOURS (math -s0 "$seconds_since_last_commit/3600")

            # Sub-hours and sub-minutes
            set DAYS (math -s0 "$seconds_since_last_commit / 86400")
            set SUB_HOURS (math -s0 "$HOURS % 24")
            set SUB_MINUTES (math -s0 "$MINUTES % 60")

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
    set -l git_info (_git_time_since_commit)
    set -l git_status (_git_status)

    set git_info "$git_info$git_status"
    echo -n -s $git_info
end
