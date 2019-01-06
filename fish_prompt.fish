# name: cyan
set -g cyan (set_color 33FFFF)
set -g yellow (set_color CCFF00)
set -g red (set_color -o red)
set -g green (set_color -o green)
set -g white (set_color -o white)
set -g blue (set_color -o blue)
set -g magenta (set_color -o magenta)
set -g normal (set_color normal)
set -g purple (set_color -o purple)

set -g FISH_GIT_PROMPT_EQUAL_REMOTE "$magenta=$normal"
set -g FISH_GIT_PROMPT_AHEAD_REMOTE "$magenta>$normal"
set -g FISH_GIT_PROMPT_BEHIND_REMOTE "$magenta<$normal"
set -g FISH_GIT_PROMPT_DIVERGED_REMOTE "$red<>$normal"

function _git_branch_name -d "Display current branch's name"
  echo (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
end

function _git_short_sha -d "Display short hash"
    echo (command git rev-parse --short HEAD 2> /dev/null)
end

function _git_ahead -d "git repository is ahead or behind origin"
  set -l commits (command git rev-list --left-right '@{upstream}...HEAD' 2> /dev/null)

  if [ $status != 0 ]
    return
  end

  set -l behind (count (for arg in $commits; echo $arg; end | grep '^<'))
  set -l ahead (count (for arg in $commits; echo $arg; end | grep -v '^<'))

  switch "$ahead $behind"
    case '' # no upstream
        echo ""
    case '0 0' # equal to upstream
        echo "$FISH_GIT_PROMPT_EQUAL_REMOTE"
    case '* 0' # ahead of upstream
        echo "$FISH_GIT_PROMPT_AHEAD_REMOTE"
    case '0 *' # behind upstream
        echo "$FISH_GIT_PROMPT_BEHIND_REMOTE"
    case '*' # diverged from upstream
        echo "$FISH_GIT_PROMPT_DIVERGED_REMOTE"
  end
end

function fish_prompt
    set -l cwd $green(basename (prompt_pwd))
    if [ (command git rev-parse --git-dir 2> /dev/null) ]
        set -l git_branch $yellow(_git_branch_name)
        set -l git_sha $magenta(_git_short_sha)$normal
        set -l git_branch_ahead (_git_ahead)

        set git_info "$green($git_branch#$normal$git_sha$green)$normal $git_branch_ahead"
    end

    echo -n -s $normal $cyan (whoami) '@' $normal $blue (hostname -s) $normal ' ' $cwd ' '  $git_info $yellow' ✗ '$normal
end
