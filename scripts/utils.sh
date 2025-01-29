#!/usr/bin/env bash

# $1: option
# $2: default value
tmux_get() {
    local value
    value="$(tmux show -gqv "$1")"
    [ -n "$value" ] && echo "$value" || echo "$2"
}

# $1: option
# $2: value
tmux_set() {
    tmux set-option -gq "$1" "$2"
}

theme2color() {
    local tc
    tc=$(tmux_get '@tmux_power_theme' 'gold')
    case $tc in
        'gold' )
            tc='#ffb86c'
            ;;
        'redwine' )
            tc='#b34a47'
            ;;
        'moon' )
            tc='#00abab'
            ;;
        'forest' )
            tc='#228b22'
            ;;
        'violet' )
            tc='#9370db'
            ;;
        'snow' )
            tc='#fffafa'
            ;;
        'coral' )
            tc='#ff7f50'
            ;;
        'sky' )
            tc='#87ceeb'
            ;;
        'everforest' )
            tc='#a7c080'
            ;;
    esac
    echo $tc
}

normalize_padding() {
    percent_len=${#1}
    max_len=${2:-5}
    let diff_len=$max_len-$percent_len
    # if the diff_len is even, left will have 1 more space than right
    let left_spaces=($diff_len + 1)/2
    let right_spaces=($diff_len)/2
    printf "%${left_spaces}s%s%${right_spaces}s\n" "" $1 ""
}
