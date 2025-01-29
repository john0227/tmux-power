#!/usr/bin/env bash

# From https://github.com/2KAbhishek/tmux2k/blob/main/scripts/git.sh

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

hide_status=$(tmux_get '@tmux2k-git-disable-status' 'true')
current_symbol=$(tmux_get '@tmux2k-git-show-current-symbol' '')
diff_symbol=$(tmux_get '@tmux2k-git-show-diff-symbol' '')
no_repo_message=$(tmux_get '@tmux2k-git-no-repo-message' '')

TC=$(theme2color)
BG=$(tmux_get @tmux_power_bg "default")
G0=$(tmux_get @tmux_power_g0 "#262626")
G2=$(tmux_get @tmux_power_g2 "#3a3a3a")
GH=$(tmux_get @tmux_power_gh "#45d266")
FOLDER=$(tmux_get @tmux_power_folder "#7082DB")

rarrow=$(tmux_get '@tmux_power_right_arrow_icon' '')
larrow=$(tmux_get '@tmux_power_left_arrow_icon' '')

get_changes() {
    declare -i added=0
    declare -i modified=0
    declare -i updated=0
    declare -i deleted=0

    for i in $(git -C "$path" status -s); do
        case $i in
        'A') added+=1 ;;
        'M') modified+=1 ;;
        'U') updated+=1 ;;
        'D') deleted+=1 ;;
        esac
    done

    output=""
    [ $added -gt 0 ] && output+="${added} "
    [ $modified -gt 0 ] && output+=" ${modified} "
    [ $updated -gt 0 ] && output+=" ${updated} "
    [ $deleted -gt 0 ] && output+=" ${deleted} "

    echo "$output"
}

get_pane_dir() {
    nextone="false"
    for i in $(tmux list-panes -F "#{pane_active} #{pane_current_path}"); do
        if [ "$nextone" == "true" ]; then
            echo "$i"
            return
        fi
        if [ "$i" == "1" ]; then
            nextone="true"
        fi
    done
}

check_empty_symbol() {
    symbol=$1
    if [ "$symbol" == "" ]; then
        echo "true"
    else
        echo "false"
    fi
}

check_for_changes() {
    if [ "$(check_for_git_dir)" == "true" ]; then
        if [ "$(git -C "$path" status -s)" != "" ]; then
            echo "true"
        else
            echo "false"
        fi
    else
        echo "false"
    fi
}

check_for_git_dir() {
    if [ "$(git -C "$path" rev-parse --abbrev-ref HEAD)" != "" ]; then
        echo "true"
    else
        echo "false"
    fi
}

get_origin_name() {
    if [ $(check_for_git_dir) == "true" ]; then
        origin=$(basename $(awk -F ' = ' '/\[remote "origin"\]/{f=1} f && /url = /{print $2; exit}' $path/.git/config) | sed -E 's/.git$//')
        echo "$origin"
    else
        echo ""
    fi
}

get_branch() {
    if [ $(check_for_git_dir) == "true" ]; then
        printf " %.20s" $(git -C "$path" rev-parse --abbrev-ref HEAD)
    else
        echo ""
    fi
}

get_message() {
    if [ $(check_for_git_dir) == "true" ]; then
        origin="$(get_origin_name)"
        branch="$(get_branch)"

        prefix="#[fg=$GH,bg=$BG]$larrow#[fg=$G0,bg=$GH,bold]"
        suffix="#[fg=$GH,bg=$BG,nobold]$rarrow"

        if [ $(check_empty_symbol "$current_symbol") == "true" ]; then
            echo "$prefix $origin $branch $suffix"
        else
            echo "$prefix $current_symbol $origin $branch $suffix"
        fi
    else
        prefix="#[fg=$FOLDER,bg=$BG]$larrow#[fg=$G0,bg=$FOLDER,bold]"
        suffix="#[fg=$FOLDER,bg=$BG,nobold]$rarrow"

        cwd="$(basename "$path")"
        echo "$prefix  $cwd $suffix"
    fi
}

main() {
    path=$(get_pane_dir)
    get_message
}

main