# shellcheck shell=sh

# Sourced by tmux-session and agent-session: where projects live.
# PROJECT_PARENTS holds directories whose children are projects; PROJECT_DIRS
# holds projects themselves. Space separated (no spaces in paths); export
# either to override.

: "${PROJECT_PARENTS:=$HOME/100_projects $HOME/102_school_work $HOME/103_school_proj $HOME/work}"
: "${PROJECT_DIRS:=$HOME/nixos $HOME/nixos/config $HOME/201_resumes $HOME/org}"

# Print every project directory, one per line.
project_list() {
    # Deliberate word splitting on both lists.
    # shellcheck disable=SC2086
    fd . $PROJECT_PARENTS --type=dir --max-depth=1 --full-path 2>/dev/null |
        sed 's:/*$::'
    # shellcheck disable=SC2086
    printf '%s\n' $PROJECT_DIRS
}

# tmux session name for a directory: its last two components relative to
# $HOME (~/100_projects/notes -> 100_projects_notes, ~/nixos -> nixos), with
# dots and colons replaced since tmux reserves them in target names.
session_name() {
    printf '%s\n' "$1" |
        sed "s:/*$::; s:^$HOME/*::" |
        awk -F/ '{
            if (NF == 0 || $0 == "") printf "home";
            else if (NF > 1) printf "%s_%s", $(NF-1), $NF;
            else printf "%s", $NF
        }' |
        tr '.:' '__'
}
