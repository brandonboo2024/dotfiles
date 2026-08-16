# shellcheck shell=sh

# Sourced, not executed. Where the session scripts look for projects, kept in
# one place so they cannot drift apart.
#
# Two lists, because there are two kinds of thing: directories whose immediate
# children are each a project, and directories that are themselves a project.
# Space separated, so no spaces in the paths. Override by exporting either
# before calling.

: "${PROJECT_PARENTS:=$HOME/100_projects $HOME/102_school_work $HOME/103_school_proj}"
: "${PROJECT_DIRS:=$HOME/nixos $HOME/nixos/config $HOME/201_resumes}"

# Print every project directory, one per line.
project_list() {
    # Deliberate word splitting on both lists.
    # shellcheck disable=SC2086
    fd . $PROJECT_PARENTS --type=dir --max-depth=1 --full-path 2>/dev/null |
        sed 's:/*$::'
    # shellcheck disable=SC2086
    printf '%s\n' $PROJECT_DIRS
}

# Session name for a project directory. Names are relative to $HOME and keep
# the last two components, so ~/100_projects/notes and
# ~/102_school_work/notes do not collapse onto one tmux session while ~/nixos
# stays plain "nixos". Dots become underscores because tmux treats them
# specially in target names.
session_name() {
    printf '%s\n' "$1" |
        sed "s:/*$::; s:^$HOME/*::" |
        awk -F/ '{
            if (NF == 0 || $0 == "") printf "home";
            else if (NF > 1) printf "%s_%s", $(NF-1), $NF;
            else printf "%s", $NF
        }' |
        tr . _
}
